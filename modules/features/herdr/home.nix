{
  config,
  lib,
  options,
  pkgs,
  ...
}:
let
  cfg = config.modules.home.herdr;
  toml = pkgs.formats.toml { };
  json = pkgs.formats.json { };
  defaultJjWorkspacePlugin = {
    id = "nathanflurry.jj-workspace";
    package = cfg.jjWorkspacePluginPackage;
    manifestFile = cfg.jjWorkspacePluginManifestFile;
    enabled = true;
  };
  defaultWorktrunkPlugin = {
    id = "worktrunk";
    package = cfg.worktrunkPluginPackage;
    manifestFile = cfg.worktrunkPluginManifestFile;
    enabled = true;
  };
  configuredPlugins =
    lib.optional cfg.enableJjWorkspacePlugin defaultJjWorkspacePlugin
    ++ lib.optional cfg.enableWorktrunkPlugin defaultWorktrunkPlugin
    ++ cfg.plugins;
  jjWorkspaceKeybindCommands =
    lib.optionals (cfg.enableJjWorkspacePlugin && cfg.pluginKeybinds.jjWorkspace.enable)
      [
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
  worktrunkKeybindCommands =
    lib.optionals (cfg.enableWorktrunkPlugin && cfg.pluginKeybinds.worktrunk.enable)
      [
        {
          key = cfg.pluginKeybinds.worktrunk.open;
          type = "plugin_action";
          command = "worktrunk.open";
          description = "Worktree: switch / create from default branch";
        }
        {
          key = cfg.pluginKeybinds.worktrunk.openCurrent;
          type = "plugin_action";
          command = "worktrunk.open-current";
          description = "Worktree: switch / create from current branch";
        }
        {
          key = cfg.pluginKeybinds.worktrunk.remove;
          type = "plugin_action";
          command = "worktrunk.remove";
          description = "Worktree: remove";
        }
      ];
  settingsWithKittyGraphics = lib.recursiveUpdate cfg.settings {
    experimental.kitty_graphics = cfg.kittyGraphics;
  };
  settingsWithTheme =
    if cfg.theme == null then
      settingsWithKittyGraphics
    else
      lib.recursiveUpdate settingsWithKittyGraphics { theme.name = cfg.theme; };
  effectiveSettings = settingsWithTheme // {
    keys = (settingsWithTheme.keys or { }) // {
      command =
        (settingsWithTheme.keys.command or [ ]) ++ jjWorkspaceKeybindCommands ++ worktrunkKeybindCommands;
    };
  };
  herdrBin = lib.getExe' cfg.package "herdr";
  pluginRegistry = builtins.map (
    plugin:
    let
      manifestPath =
        if plugin.manifestFile == null then "${plugin.package}/herdr-plugin.toml" else plugin.manifestFile;
      manifest = builtins.fromTOML (builtins.readFile manifestPath);
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
      inherit (plugin) enabled;
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
  configFileSource = toml.generate "herdr-config.toml" effectiveSettings;
  pluginsFileSource = json.generate "herdr-plugins.json" pluginRegistry;
  # Everything the running server would have to restart to pick up. A rebuild
  # that leaves all of these unchanged must not disturb running sessions.
  activationStamp = lib.concatStringsSep "\n" (
    [ (toString cfg.package) ]
    ++ lib.optional (effectiveSettings != { }) (toString configFileSource)
    ++ lib.optional (configuredPlugins != [ ]) (toString pluginsFileSource)
  );
in
{
  options.modules.home.herdr = with lib; {
    enable = mkEnableOption "Herdr terminal workspace manager for AI coding agents";

    package = mkOption {
      type = types.package;
      defaultText = literalExpression "inputs.herdr.packages.\${pkgs.stdenv.hostPlatform.system}.default";
      description = "Herdr package to install.";
    };

    jjWorkspacePluginPackage = mkOption {
      type = types.package;
      description = "Bundled jj-workspace plugin package.";
    };

    jjWorkspacePluginManifestFile = mkOption {
      type = types.path;
      description = ''
        Source manifest for the bundled jj-workspace plugin. Keeping this
        separate from the built package avoids import from derivation during
        module evaluation.
      '';
    };

    worktrunkPluginPackage = mkOption {
      type = types.package;
      description = "Bundled Herdr Worktrunk plugin package.";
    };

    worktrunkPluginManifestFile = mkOption {
      type = types.path;
      description = "Source manifest for the bundled Herdr Worktrunk plugin.";
    };

    theme = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "kanagawa";
      description = "Optional Herdr theme name override. When null, settings.theme is left untouched.";
    };

    kittyGraphics = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Herdr's experimental Kitty graphics renderer.";
    };

    sshAutoStart = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Replace interactive SSH logins with a Herdr session. The zsh startup
        files run `exec herdr` when the shell has an SSH TTY, is not already
        inside Herdr, and `HERDR_DISABLE_AUTO_START` is empty.
      '';
    };

    stopServerOnActivation = mkOption {
      type = types.bool;
      default = cfg.sshAutoStart;
      defaultText = literalExpression "config.modules.home.herdr.sshAutoStart";
      description = ''
        Stop the running Herdr server during Home Manager activation when the
        Herdr package, the generated configuration, or the plugin registry
        changed. Activations that leave those unchanged keep running sessions.

        The stop is deferred by {option}`stopServerDelaySeconds`, because it
        also kills the shell that started the rebuild.
      '';
    };

    stopServerDelaySeconds = mkOption {
      type = types.ints.positive;
      default = 10;
      description = ''
        Delay between the end of the activation and the deferred
        `herdr server stop`.
      '';
    };

    enableJjWorkspacePlugin = mkOption {
      type = types.bool;
      default = true;
      description = "Enable the bundled NathanFlurry jj workspace Herdr plugin.";
    };

    enableWorktrunkPlugin = mkOption {
      type = types.bool;
      default =
        lib.hasAttrByPath [ "modules" "home" "git" "worktrunk" "enable" ] options
        && config.modules.home.git.enable
        && config.modules.home.git.worktrunk.enable;
      defaultText = literalExpression "config.modules.home.git.enable && config.modules.home.git.worktrunk.enable";
      description = "Enable the Worktrunk plugin when Git's Worktrunk integration is enabled.";
    };

    plugins = mkOption {
      type = types.listOf (
        types.submodule (_: {
          options = {
            id = mkOption {
              type = types.str;
              description = "Plugin id matching the herdr-plugin.toml manifest.";
            };
            package = mkOption {
              type = types.package;
              description = "Package containing herdr-plugin.toml at its root.";
            };
            manifestFile = mkOption {
              type = types.nullOr types.path;
              default = null;
              description = ''
                Optional source herdr-plugin.toml. Supplying it avoids reading
                the plugin package output during module evaluation.
              '';
            };
            enabled = mkOption {
              type = types.bool;
              default = true;
              description = "Whether the plugin is enabled in Herdr.";
            };
          };
        })
      );
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

    pluginKeybinds.worktrunk = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Add default keybinds for the bundled Worktrunk plugin.";
      };
      open = mkOption {
        type = types.str;
        default = "prefix+shift+g";
        description = "Keybind for switching or creating a worktree from the default branch.";
      };
      openCurrent = mkOption {
        type = types.str;
        default = "prefix+shift+c";
        description = "Keybind for switching or creating a worktree from the current branch.";
      };
      remove = mkOption {
        type = types.str;
        default = "prefix+shift+d";
        description = "Keybind for removing a worktree.";
      };
    };

    settings = mkOption {
      inherit (toml) type;
      default = {
        onboarding = false;
        theme.name = "gruvbox";
        terminal = {
          default_shell = "zsh";
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
          switch_workspace = "prefix+shift+1..9";
          focus_agent = "prefix+alt+1..9";
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
          agent_panel_sort = "priority";
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
    ]
    ++ map (plugin: plugin.package) configuredPlugins;

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
        cache_ttl="''${HERDR_NAV_CACHE_TTL_SECONDS:-2}"
        [[ "$cache_ttl" =~ ^[0-9]+$ ]] || cache_ttl=2

        process_name_matches() {
          local name
          name=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')
          [[ "$name" =~ $vim_re ]] && return 0
          if [[ -n "$passthrough_re" ]] && printf '%s\n' "$name" | grep -Eq "$passthrough_re" 2>/dev/null; then
            return 0
          fi
          return 1
        }

        detect_forward() {
          local info name
          info=$("$herdr" pane process-info --pane "$pane" 2>/dev/null || true)
          [[ -n "$info" ]] || return 1
          while IFS= read -r name; do
            if process_name_matches "$name"; then
              return 0
            fi
          done < <(
            printf '%s\n' "$info" \
              | grep -oE '"name"[[:space:]]*:[[:space:]]*"[^"]+"' \
              | sed -E 's/.*"name"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/' \
              || true
          )
          return 1
        }

        forward=0
        cached=0
        if [[ -n "$pane" ]]; then
          cache_dir="''${XDG_RUNTIME_DIR:-''${TMPDIR:-/tmp}}/herdr-vim-navigate-''${UID:-$(id -u)}"
          cache_key=$(printf '%s' "$pane" | tr -c 'A-Za-z0-9_.-' '_')
          cache_file="$cache_dir/$cache_key"
          now=$(date +%s)
          if [[ -r "$cache_file" ]]; then
            read -r cached_at cached_forward < "$cache_file" || true
            if [[ "''${cached_at:-}" =~ ^[0-9]+$ && "''${cached_forward:-}" =~ ^[01]$ && $((now - cached_at)) -le "$cache_ttl" ]]; then
              forward="$cached_forward"
              cached=1
            fi
          fi
          if [[ "$cached" -eq 0 ]]; then
            if detect_forward; then
              forward=1
            fi
            mkdir -p "$cache_dir" 2>/dev/null || true
            printf '%s %s\n' "$now" "$forward" > "$cache_file" 2>/dev/null || true
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
          --layout=default
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
          --layout=default
          --border=rounded
          --prompt='workspace> '
          --with-nth=3..
          --color='bg:-1,bg+:#3c3836,fg:#ebdbb2,fg+:#fbf1c7,hl:#fabd2f,hl+:#fabd2f'
          --color='border:#665c54,prompt:#83a598,pointer:#fe8019,marker:#b8bb26,info:#8ec07c,spinner:#d3869b'
        )

        selected=$(
          herdr workspace list \
            | jq -r '.result.workspaces[] | [.workspace_id, .active_tab_id, .number, .label, .focused, .pane_count, .tab_count] | @tsv' \
            | awk -F '\t' '{ marker = ($5 == "true" ? "*" : " "); printf "%s\t%s\t%s%s: %s (%s panes, %s tabs)\n", $1, $2, marker, $3, $4, $6, $7 }' \
            | fzf "''${fzf_opts[@]}" \
            || true
        )

        if [[ -z ''${selected:-} ]]; then
          exit 0
        fi

        workspace_id=''${selected%%$'\t'*}
        rest=''${selected#*$'\t'}
        tab_id=''${rest%%$'\t'*}
        herdr tab focus "$tab_id" >/dev/null
      '';
    };

    xdg.configFile."herdr/config.toml" = lib.mkIf (effectiveSettings != { }) {
      source = configFileSource;
    };

    xdg.configFile."herdr/plugins.json" = lib.mkIf (configuredPlugins != [ ]) {
      source = pluginsFileSource;
    };

    # Ordered behind lib.mkAfter, because `exec` ends the startup files and
    # every other fragment must run before it.
    programs.zsh.initContent = lib.mkIf cfg.sshAutoStart (
      lib.mkOrder 2000 ''
        if [[ -n "$SSH_TTY" && -z "$HERDR_ENV" && -z "$HERDR_DISABLE_AUTO_START" ]]; then
          exec ${herdrBin}
        fi
      ''
    );

    home.activation.herdrStopStaleServer = lib.mkIf cfg.stopServerOnActivation (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        herdrStampFile="${config.xdg.stateHome}/herdr/nix-activation-stamp"
        herdrStamp=${lib.escapeShellArg activationStamp}

        herdrScheduleServerStop() {
          # The stop is deferred, because the rebuild frequently runs in a pane
          # of the server that is stopped here.
          local runtimeDir="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

          if [[ -S "$runtimeDir/bus" ]] && XDG_RUNTIME_DIR="$runtimeDir" \
            ${pkgs.systemd}/bin/systemd-run --user --collect --quiet \
              --on-active=${toString cfg.stopServerDelaySeconds} \
              --description="Stop the stale Herdr server after a Home Manager activation" \
              -- ${pkgs.bash}/bin/bash -c '${herdrBin} server stop || true'
          then
            return 0
          fi

          # No user systemd manager, for example a deploy without an open
          # session. Detach from the activation unit instead.
          ${pkgs.util-linux}/bin/setsid --fork ${pkgs.bash}/bin/bash -c \
            'sleep ${toString cfg.stopServerDelaySeconds}; ${herdrBin} server stop || true' \
            </dev/null >/dev/null 2>&1 || true
        }

        if [[ "$(cat "$herdrStampFile" 2>/dev/null || true)" != "$herdrStamp" ]]; then
          if [[ -v DRY_RUN ]]; then
            echo "Would stop the running Herdr server in ${toString cfg.stopServerDelaySeconds} seconds"
          else
            verboseEcho "Herdr changed, stopping the running server in ${toString cfg.stopServerDelaySeconds} seconds"
            herdrScheduleServerStop
            mkdir -p "$(dirname "$herdrStampFile")"
            printf '%s\n' "$herdrStamp" > "$herdrStampFile"
          fi
        fi
      ''
    );

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
