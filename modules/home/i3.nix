_:
{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.home.i3;
in
{

  options.modules.home.i3 = {
    enable = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = "enable i3";
    };
  };

  config = mkIf cfg.enable {
    xsession = {
      enable = true;
      scriptPath = ".hm-xsession";
      windowManager.i3 = {
        enable = true;
        config = {
          terminal = "kitty";
        };
        extraConfig = ''
          set $hyper Mod4+Shift+Ctrl+Mod1
          set $meh Mod1+Shift+Ctrl

          bindsym $hyper+i exec "kitty"
          bindsym $hyper+space exec "kitty"
        '';
      };
    };
    programs.i3status-rust.enable = true;
  };
}
