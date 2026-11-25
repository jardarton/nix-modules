{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.modules.home.hypr;
  inherit (lib) mkForce mkIf;
in
{

  programs = {
    hyprlock = mkIf cfg.hyprlock {
      enable = true;
      package = pkgs.hyprlock;

      settings = {
        background = mkForce [
          {
            monitor = "";
            blur_passes = mkForce 0;
            blur_size = mkForce 0;
            path = cfg.lockpaper;
          }
        ];

        label = [
          {
            # Clock
            monitor = "";
            text = "cmd[update:1000] date +'%d-%m-%Y %H:%M'";
            shadow_passes = 1;
            shadow_boost = 1;
            font_size = 28;
            position = "-40, 80";
            halign = "right";
            valign = "bottom";
          }

          {
            # "Locked" text
            monitor = "";
            text = " Låst";
            shadow_passes = 1;
            shadow_boost = 1;
            font_size = 24;
            position = "80, 80";
            halign = "left";
            valign = "bottom";
          }
        ];
      };
    };
  };

  wayland.windowManager.hyprland = {
    settings = {
      bind = [
        "$mainMod, X, exec, hyprlock"
      ];
    };
  };

}
