_:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.home.ai;
  claudeCfg = cfg.claude;
  json = pkgs.formats.json { };

  # YAML frontmatter for agent/command markdown. Values are emitted as JSON
  # scalars, which YAML accepts, so descriptions containing ": " or newlines are safe.
  frontmatterValue =
    value:
    if lib.isList value then
      builtins.toJSON (lib.concatStringsSep ", " value)
    else if lib.isBool value then
      lib.boolToString value
    else
      builtins.toJSON value;

  mkFrontmatter =
    attrs:
    let
      present = lib.filterAttrs (_: value: value != null && value != [ ]) attrs;
    in
    lib.optionalString (present != { }) ''
      ---
      ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList (name: value: "${name}: ${frontmatterValue value}") present
      )}
      ---
    '';

  mkMarkdown = frontmatter: body: mkFrontmatter frontmatter + "\n" + body;

  extraFrontmatterOption = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.oneOf [
        lib.types.str
        lib.types.bool
        (lib.types.listOf lib.types.str)
      ]
    );
    default = { };
    example = lib.literalExpression ''{ "disable-model-invocation" = true; }'';
    description = "Additional frontmatter keys, for fields this module does not model yet.";
  };

  agentModule = lib.types.submodule (_: {
    options = {
      description = lib.mkOption {
        type = lib.types.str;
        description = "When Claude should delegate to this agent; shown in the agent listing.";
      };

      tools = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [
          "Read"
          "Grep"
          "Bash"
        ];
        description = "Tools the agent may use. Empty means inherit every tool.";
      };

      model = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "sonnet";
        description = "Model override for the agent; null inherits the session model.";
      };

      extraFrontmatter = extraFrontmatterOption;

      prompt = lib.mkOption {
        type = lib.types.lines;
        description = "System prompt body of the agent definition.";
      };
    };
  });

  commandModule = lib.types.submodule (_: {
    options = {
      description = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "One-line summary shown in the slash-command listing.";
      };

      argumentHint = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "<pr-number>";
        description = "Argument hint rendered after the command name.";
      };

      allowedTools = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [ "Bash(git diff:*)" ];
        description = "Tools the command may use without a permission prompt.";
      };

      model = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Model override for the command; null inherits the session model.";
      };

      extraFrontmatter = extraFrontmatterOption;

      body = lib.mkOption {
        type = lib.types.lines;
        description = "Prompt body of the command. Use $ARGUMENTS, $1, $2 for arguments.";
      };
    };
  });

  skillModule = lib.types.submodule (_: {
    options = {
      source = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        example = lib.literalExpression ''inputs.some-skill-source + "/skills/herdr"'';
        description = ''
          Directory holding an already-written `SKILL.md`, linked in wholesale along
          with any scripts or references beside it. Use this to consume a skill authored
          outside Nix; it is mutually exclusive with {option}`description` and
          {option}`body`.
        '';
      };

      description = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "When the skill applies; this is what Claude matches against.";
      };

      allowedTools = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [ "Bash(nixfmt:*)" ];
        description = "Tools the skill may use without a permission prompt.";
      };

      extraFrontmatter = extraFrontmatterOption;

      body = lib.mkOption {
        type = lib.types.nullOr lib.types.lines;
        default = null;
        description = "Instruction body written to SKILL.md.";
      };

      files = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.either lib.types.path (
            lib.types.submodule (_: {
              options.text = lib.mkOption {
                type = lib.types.lines;
                description = "Inline contents of the file.";
              };
            })
          )
        );
        default = { };
        example = lib.literalExpression ''
          {
            "references/style.md".text = "Use nixfmt.";
            "scripts/check.sh" = ./check.sh;
          }
        '';
        description = ''
          Extra files placed next to SKILL.md, keyed by path relative to the skill
          directory. Use these for the reference material a skill loads on demand.
        '';
      };
    };
  });

  skillFiles = lib.concatMapAttrs (
    skillName: skill:
    if skill.source != null then
      {
        # recursive links each file individually, so the skill directory stays a real
        # directory that hand-written files can sit in.
        ".claude/skills/${skillName}" = {
          inherit (skill) source;
          recursive = true;
        };
      }
    else
      {
        ".claude/skills/${skillName}/SKILL.md".text = mkMarkdown (
          {
            name = skillName;
            inherit (skill) description;
            allowed-tools = skill.allowedTools;
          }
          // skill.extraFrontmatter
        ) skill.body;
      }
      // lib.mapAttrs' (
        filePath: file:
        lib.nameValuePair ".claude/skills/${skillName}/${filePath}" (
          if lib.isAttrs file && file ? text then { inherit (file) text; } else { source = file; }
        )
      ) skill.files
  ) claudeCfg.skills;

  settingsFile = json.generate "claude-settings.json" claudeCfg.settings;

  # Claude Code owns settings.json at runtime (/config toggles, plugin state, accepted
  # dialogs), so declared keys are merged in rather than replacing the file.
  mergeSettings = pkgs.writeShellScript "claude-merge-settings" ''
    set -euo pipefail

    target="$HOME/.claude/settings.json"
    declared=${settingsFile}

    mkdir -p "$(dirname "$target")"

    # An earlier generation, or a hand-rolled config, may have symlinked this into the store.
    if [ -L "$target" ]; then
      rm -f "$target"
    fi

    if [ ! -s "$target" ]; then
      printf '{}\n' >"$target"
      chmod 0600 "$target"
    fi

    if ! ${lib.getExe pkgs.jq} -e 'type == "object"' "$target" >/dev/null 2>&1; then
      printf 'claude: %s is not a JSON object, refusing to merge declarative settings\n' "$target" >&2
      exit 0
    fi

    tmp=$(mktemp "$target.XXXXXX")
    trap 'rm -f "$tmp"' EXIT
    ${lib.getExe pkgs.jq} --slurpfile declared "$declared" '. * $declared[0]' "$target" >"$tmp"
    # Copy rather than rename so the file keeps its existing mode.
    cat "$tmp" >"$target"
  '';

  # Resolves claude from PATH on purpose: the native installer shadows the Nix package,
  # so this follows whichever claude the user actually runs.
  dangerousWrapper = pkgs.writeShellScriptBin claudeCfg.dangerousAlias ''
    exec claude --dangerously-skip-permissions "$@"
  '';
in
{
  options.modules.home.ai.claude = {
    dangerousAlias = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "claude-yolo";
      example = "ccy";
      description = ''
        Name of a wrapper on PATH that runs `claude --dangerously-skip-permissions`,
        forwarding any extra arguments. A wrapper rather than a shell alias, so it also
        works from scripts and non-interactive shells such as Herdr pane commands. Set
        to null to omit it.
      '';
    };

    settings = lib.mkOption {
      inherit (json) type;
      default = { };
      example = lib.literalExpression ''
        {
          model = "opus";
          editorMode = "vim";
          tui = "fullscreen";
          permissions.allow = [ "Bash(git diff:*)" ];
        }
      '';
      description = ''
        Settings merged into `~/.claude/settings.json` during activation. Declared keys
        win; keys Claude Code writes itself survive, so `/config` keeps working. Follows
        the Claude Code settings schema; see
        `https://docs.claude.com/en/docs/claude-code/settings`.
      '';
    };

    memory = lib.mkOption {
      type = lib.types.nullOr lib.types.lines;
      default = null;
      example = ''
        - Prefer `rg` over `grep`.
        - Never commit unless asked.
      '';
      description = ''
        Instructions written to `~/.claude/CLAUDE.md`, loaded in every project. This
        file becomes a read-only store symlink, so the `#` memory shortcut cannot
        append to it.
      '';
    };

    agents = lib.mkOption {
      type = lib.types.attrsOf agentModule;
      default = { };
      example = lib.literalExpression ''
        {
          nix-reviewer = {
            description = "Review Nix module changes for override-friendliness.";
            tools = [ "Read" "Grep" "Glob" ];
            prompt = "You review Nix modules...";
          };
        }
      '';
      description = ''
        Subagents written to `~/.claude/agents/<name>.md`. Only the declared files are
        symlinked, so agents created through `/agents` sit alongside them untouched.
      '';
    };

    commands = lib.mkOption {
      type = lib.types.attrsOf commandModule;
      default = { };
      example = lib.literalExpression ''
        {
          switch = {
            description = "Rebuild and switch this host";
            allowedTools = [ "Bash(nh:*)" ];
            body = "Run `nh os switch` and report what changed.";
          };
        }
      '';
      description = "Slash commands written to `~/.claude/commands/<name>.md`.";
    };

    skills = lib.mkOption {
      type = lib.types.attrsOf skillModule;
      default = { };
      example = lib.literalExpression ''
        {
          nix-modules = {
            description = "Use when editing modules in this flake.";
            body = "Follow the dendritic pattern...";
            files."references/style.md".text = "Use nixfmt.";
          };
        }
      '';
      description = ''
        Skills written to `~/.claude/skills/<name>/SKILL.md`. Only the declared files
        are symlinked and `~/.claude/skills` itself stays a real directory, so skills
        added by hand live alongside these. Project skills in a repository's
        `.claude/skills` are a separate source and are unaffected.
      '';
    };

  };

  config = lib.mkIf (cfg.enable && claudeCfg.enable) {
    assertions = lib.mapAttrsToList (skillName: skill: {
      assertion =
        if skill.source != null then
          skill.description == null && skill.body == null && skill.files == { }
        else
          skill.description != null && skill.body != null;
      message =
        if skill.source != null then
          "modules.home.ai.claude.skills.${skillName}: source is mutually exclusive with description, body, and files."
        else
          "modules.home.ai.claude.skills.${skillName}: set either source, or both description and body.";
    }) claudeCfg.skills;

    home.packages = lib.mkIf (claudeCfg.dangerousAlias != null) [ dangerousWrapper ];

    home.file = lib.mkMerge [
      (lib.mkIf (claudeCfg.memory != null) {
        ".claude/CLAUDE.md".text = claudeCfg.memory;
      })

      (lib.mapAttrs' (
        agentName: agent:
        lib.nameValuePair ".claude/agents/${agentName}.md" {
          text = mkMarkdown (
            {
              name = agentName;
              inherit (agent)
                description
                tools
                model
                ;
            }
            // agent.extraFrontmatter
          ) agent.prompt;
        }
      ) claudeCfg.agents)

      (lib.mapAttrs' (
        commandName: command:
        lib.nameValuePair ".claude/commands/${commandName}.md" {
          text = mkMarkdown (
            {
              inherit (command) description model;
              argument-hint = command.argumentHint;
              allowed-tools = command.allowedTools;
            }
            // command.extraFrontmatter
          ) command.body;
        }
      ) claudeCfg.commands)

      skillFiles
    ];

    home.activation = lib.mkIf (claudeCfg.settings != { }) {
      claudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] "run ${mergeSettings}";
    };
  };
}
