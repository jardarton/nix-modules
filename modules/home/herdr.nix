{ localFlake, withSystem, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.home.herdr;
  toml = pkgs.formats.toml { };
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
          goto = "prefix+tab";
          workspace_picker = "prefix+w";
          new_workspace = "prefix+o";
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
          focus_pane_left = "ctrl+h";
          focus_pane_down = "ctrl+j";
          focus_pane_up = "ctrl+k";
          focus_pane_right = "ctrl+l";
          navigate_pane_left = "h";
          navigate_pane_down = "j";
          navigate_pane_up = "k";
          navigate_pane_right = "l";
          navigate_workspace_up = "up";
          navigate_workspace_down = "down";
          toggle_sidebar = "prefix+shift+b";
          copy_mode = "prefix+[";
          resize_mode = "prefix+r";
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
    home.packages = [ cfg.package ];

    xdg.configFile."herdr/config.toml" = lib.mkIf (cfg.settings != { }) {
      source = toml.generate "herdr-config.toml" cfg.settings;
    };
  };
}
