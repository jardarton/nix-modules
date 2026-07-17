{ config
, inputs
, lib
, pkgs
, ...
}:
with lib;
{

  wayland.windowManager.hyprland = {

    settings = {
      # UI
      general = {
        allow_tearing = false;
        border_size = 2;
        gaps_in = 2;
        gaps_out = 5;
        layout = "scrolling";
        resize_corner = 2;
        resize_on_border = true;
      };
      decoration = {
        blur = {
          enabled = true;
          brightness = 1;
          contrast = 1.0;
          ignore_opacity = false;
          new_optimizations = true;
          passes = 3;
          popups = true;
          size = 4;
          vibrancy = 0.1;
          vibrancy_darkness = 0.50;
          xray = false;
        };
        dim_inactive = lib.mkDefault false;
        dim_strength = 0.2;
        rounding = 16;
        active_opacity = 1.0;
        inactive_opacity = 1.0;

        shadow = {
          enabled = true;
          range = 4;
          render_power = 4;

        };
      };
      animations = {
        enabled = true;
        animation = [
          "border, 1, 10, default"
          "fade, 1, 7, default"
          "windows, 1, 5, myBezier"
          "windowsMove, 1, 5, myBezier"
          "windowsOut, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 20%"
          "workspaces, 1, 10, overshot , slidevert"
        ];
        bezier = [
          "myBezier, 0.05, 0.9, 0.1, 1.1"
          "overshot, 0.05, 0.9, 0.1, 1.1"
        ];
      };

    };
  };
}
