{ localFlake, ... }:
{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.home.sway;
in
{

  options.modules.home.sway = {
    enable = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = "enable sway";
    };
  };

  config = mkIf cfg.enable {
    wayland.windowManager.sway = {
      enable = true;
      config = rec {
        modifier = "Mod4";
        # Use kitty as default terminal
        terminal = "kitty";
        startup = [
          # Launch Firefox on start
          { command = "firefox"; }
        ];
      };
    };
  };
}
