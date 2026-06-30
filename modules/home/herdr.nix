{ localFlake, withSystem, ... }:
{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.modules.home.herdr;
  toml = pkgs.formats.toml { };
  json = pkgs.formats.json { };
  mkHerdrPluginPackage =
    {
      pluginId,
      src,
      rustPackage,
    }:
    pkgs.runCommand "herdr-plugin-${lib.replaceStrings [ "." ] [ "-" ] pluginId}"
      { }
      ''
        mkdir -p "$out/target/release"
        cp ${src}/herdr-plugin.toml "$out/herdr-plugin.toml"
        cp ${rustPackage}/bin/${rustPackage.meta.mainProgram or rustPackage.pname} "$out/target/release/${rustPackage.meta.mainProgram or rustPackage.pname}"
      '';
  defaultJjWorkspaceRustPackage = pkgs.rustPlatform.buildRustPackage {
    pname = "jj-workspace";
    version = "0.1.0";
    src = localFlake.inputs.herdr-plugin-jj-workspace;
    cargoLock.lockFile = localFlake.inputs.herdr-plugin-jj-workspace + "/Cargo.lock";
    meta.mainProgram = "jj-workspace";
  };
  defaultJjWorkspacePlugin = {
    id = "nathanflurry.jj-workspace";
    package = mkHerdrPluginPackage {
      pluginId = "nathanflurry.jj-workspace";
      src = localFlake.inputs.herdr-plugin-jj-workspace;
      rustPackage = defaultJjWorkspaceRustPackage;
    };
    enabled = true;
  };
  configuredPlugins =
    lib.optional cfg.enableJjWorkspacePlugin defaultJjWorkspacePlugin
    ++ cfg.plugins;
  jjWorkspaceKeybindCommands = lib.optionals (cfg.enableJjWorkspacePlugin && cfg.pluginKeybinds.jjWorkspace.enable) [
    {
      key = cfg.pluginKeybinds.jjWorkspace.new;
      type = "pane";
      command = "herdr plugin action invoke nathanflurry.jj-workspace.new";
      description = "New jj workspace";
    }
    {
      key = cfg.pluginKeybinds.jjWorkspace.remove;
      type = "pane";
      command = "herdr plugin action invoke nathanflurry.jj-workspace.remove";
      description = "Remove jj workspace";
    }
  ];
  effectiveSettings =
    cfg.settings
    // {
      keys = (cfg.settings.keys or { }) // {
        command = (cfg.settings.keys.command or [ ]) ++ jjWorkspaceKeybindCommands;
      };
    };
  pluginRegistry = builtins.map (
    plugin:
    let
      manifest = builtins.fromTOML (builtins.readFile "${plugin.package}/herdr-plugin.toml");
    in
    {
      plugin_id = plugin.id;
      inherit (manifest)
        name
        version
        min_herdr_version
        ;
      description = manifest.description or null;
      manifest_path = "${plugin.package}/herdr-plugin.toml";
      plugin_root = toString plugin.package;
      enabled = plugin.enabled;
      platforms = manifest.platforms or null;
      build = manifest.build or [ ];
      actions = manifest.actions or [ ];
      events = manifest.events or [ ];
      panes = manifest.panes or [ ];
      link_handlers = manifest.link_handlers or [ ];
      source.kind = "local";
      warnings = [ ];
    }
  ) configuredPlugins;
  pluginConfigDirName =
    pluginId:
    let
      chars = lib.stringToCharacters pluginId;
      mapped = builtins.map (
        ch:
        if builtins.match "[a-z0-9._-]" ch != null then
          ch
        else
          let
            code = lib.toHexString (lib.strings.charToInt ch);
            normalized = if lib.stringLength code == 1 then "0${code}" else code;
          in
          "%${lib.toUpper normalized}"
      ) chars;
      component = lib.concatStrings mapped;
      stem = builtins.head (lib.splitString "." component);
      reserved = [
        "CON"
        "PRN"
        "AUX"
        "NUL"
        "COM1"
        "COM2"
        "COM3"
        "COM4"
        "COM5"
        "COM6"
        "COM7"
        "COM8"
        "COM9"
        "LPT1"
        "LPT2"
        "LPT3"
        "LPT4"
        "LPT5"
        "LPT6"
        "LPT7"
        "LPT8"
        "LPT9"
      ];
    in
    if component == "" then
      "%plugin"
    else if lib.hasSuffix "." component then
      lib.removeSuffix "." component + "%2E"
    else if builtins.elem (lib.toUpper stem) reserved then
      "%${component}"
    else
      component;
in
{
  options.modules.home.herdr = with lib; {
    enable = mkEnableOption "Herdr terminal workspace manager for AI coding agents";

    package = mkOption {
      type = types.package;
      default = withSystem pkgs.stdenv.hostPlatform.system (
        { system, ... }:
        localFlake.inputs.herdr.packages.${system}.default
      );
      defaultText = literalExpression "localFlake.inputs.herdr.packages.\${pkgs.stdenv.hostPlatform.system}.default";
      description = "Herdr package to install.";
    };

    enableJjWorkspacePlugin = mkOption {
      type = types.bool;
      default = true;
      description = "Enable the bundled NathanFlurry jj workspace Herdr plugin.";
    };

    plugins = mkOption {
      type = types.listOf (types.submodule ({ ... }: {
        options = {
          id = mkOption {
            type = types.str;
            description = "Plugin id matching the herdr-plugin.toml manifest.";
          };
          package = mkOption {
            type = types.package;
            description = "Package containing herdr-plugin.toml at its root.";
          };
          enabled = mkOption {
            type = types.bool;
            default = true;
            description = "Whether the plugin is enabled in Herdr.";
          };
        };
      }));
      default = [ ];
      example = literalExpression ''
        [
          {
            id = "example.layout";
            package = pkgs.callPackage ./my-herdr-plugin.nix { };
          }
        ]
      '';
      description = "Declarative Herdr plugins registered via ~/.config/herdr/plugins.json.";
    };

    pluginKeybinds.jjWorkspace = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Add default keybinds for the bundled jj workspace plugin.";
      };
      new = mkOption {
        type = types.str;
        default = "prefix+j";
        description = "Keybind for creating a new jj workspace.";
      };
      remove = mkOption {
        type = types.str;
        default = "prefix+shift+j";
        description = "Keybind for removing the current jj workspace.";
      };
    };

    settings = mkOption {
      type = toml.type;
      default = {
        onboarding = false;
        theme.name = "gruvbox";
        terminal = {
          shell_mode = "auto";
          new_cwd = "follow";
        };
        worktrees.directory = "~/.herdr/worktrees";
        keys = {
          prefix = "ctrl+b";
          detach = "prefix+shift+d";
          goto = "prefix+g";
          workspace_picker = "prefix+w";
          new_workspace = "prefix+shift+n";
          new_worktree = "prefix+t";
          open_notification_target = "prefix+shift+o";
          reload_config = "prefix+comma";
          rename_workspace = "prefix+shift+r";
          close_workspace = "prefix+shift+q";
          last_pane = "prefix+a";
          cycle_pane_next = "";
          cycle_pane_previous = "";
          new_tab = "prefix+c";
          rename_tab = "prefix+shift+w";
          close_tab = "prefix+q";
          previous_tab = "prefix+p";
          next_tab = "prefix+n";
          switch_tab = "prefix+1..9";
          split_vertical = "prefix+v";
          split_horizontal = "prefix+b";
          close_pane = "prefix+x";
          zoom = "prefix+enter";
          focus_pane_left = "";
          focus_pane_down = "";
          focus_pane_up = "";
          focus_pane_right = "";
          navigate_pane_left = "h";
          navigate_pane_down = "j";
          navigate_pane_up = "k";
          navigate_pane_right = "l";
          navigate_workspace_up = "up";
          navigate_workspace_down = "down";
          toggle_sidebar = "prefix+shift+b";
          copy_mode = "prefix+[";
          resize_mode = "prefix+r";
          command = [
            {
              key = "prefix+o";
              type = "pane";
              command = "herdr-sessionizer";
              description = "Pick a directory and create a workspace there";
            }
            {
              key = "prefix+tab";
              type = "pane";
              command = "herdr-workspace-fzf";
              description = "Fuzzy find and focus a workspace";
            }
            {
              key = "ctrl+h";
              type = "shell";
              command = "herdr-vim-navigate left";
              description = "Navigate left (Vim/Herdr)";
            }
            {
              key = "ctrl+j";
              type = "shell";
              command = "herdr-vim-navigate down";
              description = "Navigate down (Vim/Herdr)";
            }
            {
              key = "ctrl+k";
              type = "shell";
              command = "herdr-vim-navigate up";
              description = "Navigate up (Vim/Herdr)";
            }
            {
              key = "ctrl+l";
              type = "shell";
              command = "herdr-vim-navigate right";
              description = "Navigate right (Vim/Herdr)";
            }
          ];
        };
        ui = {
          confirm_close = true;
          prompt_new_tab_name = true;
          show_agent_labels_on_pane_borders = true;
          agent_panel_scope = "all";
          toast = {
            delivery = "herdr";
            delay_seconds = 1;
            herdr.position = "bottom-right";
            clipboard = {
              enabled = true;
              position = "bottom-center";
            };
          };
          sound.enabled = false;
        };
        session.resume_agents_on_restore = true;
        advanced.scrollback_limit_bytes = 10485760;
        experimental = {
          pane_history = false;
          allow_nested = false;
          kitty_graphics = false;
        };
      };
      example = literalExpression ''
        {
          onboarding = false;
          theme.name = "gruvbox";
          ui.toast.delivery = "herdr";
        }
      '';
      description = "Settings written to ~/.config/herdr/config.toml.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      cfg.package
      pkgs.fd
      pkgs.fzf
      pkgs.jq
    ] ++ map (plugin: plugin.package) configuredPlugins;

    home.file.".local/scripts/herdr-vim-navigate" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        set -euo pipefail

        dir="''${1:?usage: herdr-vim-navigate <left|down|up|right>}"
        herdr="''${HERDR_BIN_PATH:-herdr}"
        pane="''${HERDR_ACTIVE_PANE_ID:-''${HERDR_PANE_ID:-}}"

        case "$dir" in
          left) key="ctrl+h" ;;
          down) key="ctrl+j" ;;
          up) key="ctrl+k" ;;
          right) key="ctrl+l" ;;
          *) echo "herdr-vim-navigate: unknown direction: $dir" >&2; exit 2 ;;
        esac

        vim_re='^g?(view|l?n?vim?x?)(diff)?$'
        passthrough_re="''${HERDR_NAV_PASSTHROUGH_RE:-}"

        forward=0
        if [[ -n "$pane" ]] && command -v jq >/dev/null 2>&1; then
          if "$herdr" pane process-info --pane "$pane" 2>/dev/null \
            | jq -e --arg vim "$vim_re" --arg pass "$passthrough_re" \
                '.result.process_info.foreground_processes[]?.name
                 | ascii_downcase
                 | select(test($vim) or ($pass != "" and (try test($pass) catch false)))' >/dev/null 2>&1; then
            forward=1
          fi
        fi

        if [[ "$forward" -eq 1 && -n "$pane" ]]; then
          exec "$herdr" pane send-keys "$pane" "$key"
        else
          exec "$herdr" pane focus --direction "$dir" --current
        fi
      '';
    };

    home.file.".local/scripts/herdr-sessionizer" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        set -euo pipefail

        fzf_opts=(
          --height=80%
          --reverse
          --border=rounded
          --prompt='directory> '
          --color='bg:-1,bg+:#3c3836,fg:#ebdbb2,fg+:#fbf1c7,hl:#fabd2f,hl+:#fabd2f'
          --color='border:#665c54,prompt:#83a598,pointer:#fe8019,marker:#b8bb26,info:#8ec07c,spinner:#d3869b'
        )

        if [[ $# -eq 1 ]]; then
          selected=$1
        else
          selected=$(fd . ~ -t d -d 3 -H -E Applications -E Library -E Music -E Movies -E Pictures -E Downloads -E Desktop -E Documents | fzf "''${fzf_opts[@]}" || true)
        fi

        if [[ -z ''${selected:-} ]]; then
          exit 0
        fi

        selected=$(realpath "$selected")
        selected_name=$(basename "$selected" | tr . _)

        herdr workspace create --cwd "$selected" --label "$selected_name" --focus >/dev/null
      '';
    };

    home.file.".local/scripts/herdr-workspace-fzf" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        set -euo pipefail

        fzf_opts=(
          --height=80%
          --reverse
          --border=rounded
          --prompt='workspace> '
          --with-nth=2..
          --color='bg:-1,bg+:#3c3836,fg:#ebdbb2,fg+:#fbf1c7,hl:#fabd2f,hl+:#fabd2f'
          --color='border:#665c54,prompt:#83a598,pointer:#fe8019,marker:#b8bb26,info:#8ec07c,spinner:#d3869b'
        )

        selected=$(
          herdr workspace list \
            | jq -r '.result.workspaces[] | [.workspace_id, .number, .label, .focused, .pane_count, .tab_count] | @tsv' \
            | awk -F '\t' '{ marker = ($4 == "true" ? "*" : " "); printf "%s\t%s%s: %s (%s panes, %s tabs)\n", $1, marker, $2, $3, $5, $6 }' \
            | fzf "''${fzf_opts[@]}" \
            || true
        )

        if [[ -z ''${selected:-} ]]; then
          exit 0
        fi

        workspace_id=''${selected%%$'\t'*}
        herdr workspace focus "$workspace_id" >/dev/null
      '';
    };

    xdg.configFile."herdr/config.toml" = lib.mkIf (effectiveSettings != { }) {
      source = toml.generate "herdr-config.toml" effectiveSettings;
    };

    xdg.configFile."herdr/plugins.json" = lib.mkIf (configuredPlugins != [ ]) {
      source = json.generate "herdr-plugins.json" pluginRegistry;
    };

    home.activation.herdrPluginDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] (
      lib.concatStringsSep "\n" (
        builtins.map (
          plugin:
          let
            configDir = pluginConfigDirName plugin.id;
          in
          ''
            mkdir -p "$HOME/.config/herdr/plugins/config/${configDir}"
            mkdir -p "$HOME/.local/state/herdr/plugins/${configDir}"
          ''
        ) configuredPlugins
      )
    );
  };
}
