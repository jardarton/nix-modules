{ config
, inputs
, lib
, pkgs
, ...
}:
let
  cfg = config.modules.home.hypr;
in
with lib;
{
  wayland.windowManager.hyprland = {
    settings = {
      "$terminal" = "kitty";
      "$fileManager" = "uwsm app -- nautilus";
      "$menu" = "uwsm app -- ${cfg.launcher}";

      exec-once = [
      ];

      misc = {
        disable_hyprland_logo = true;
        # disable_splash_rendering = true;
        # force_default_wallpaper = -1;
      };
      windowrule = [
        # "opacity 0.85 0.65,class:firefox"
        # "opacity 0.85,class:org.gnome.nautilus"
      ];
    };
  };
}
