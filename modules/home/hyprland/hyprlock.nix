{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.modules.home.hypr;
in
with lib;
{

  programs = {
    hyprlock = mkIf cfg.hyprlock {
      enable = true;
      package = pkgs.hyprlock;

      settings = {
        # "$entry_background_color" = "rgba(43434341)";
        # "$entry_border_color" = "rgba(21212125)";
        # "$entry_color" = "rgba(C6C6C6FF)";
        # "$font_family" = "Noto Sans NF";
        # "$font_family_clock" = "Noto Sans NF";
        # "$font_symbols" = "Noto Sans NF";
        # "$text_color" = "rgba(E2E2E2FF)";

        background = mkForce [
          {
            monitor = "";
            blur_passes = mkForce 0;
            blur_size = mkForce 0;
            path = cfg.lockpaper;
          }
        ];

        # input-field = [
        #   {
        #     size = "350, 50";
        #     outline_thickness = 4;
        #     dots_size = 0.1;
        #     dots_spacing = 0.5;
        #     # outer_color = "$entry_border_color";
        #     # inner_color = "$entry_background_color";
        #     # font_color = "$entry_color";
        #     fade_on_empty = true;
        #     position = "0, 20";
        #     halign = "center";
        #     valign = "center";
        #     # source = "~/.config/hypr/hyprlock_monitor.conf";
        #   }
        # ];

        label = [
          {
            # Clock
            monitor = "";
            text = "cmd[update:1000] date +'%d-%m-%Y %H:%M'";
            shadow_passes = 1;
            shadow_boost = 1;
            #color = "$text_color";
            font_size = 28;
            # font_family = "$font_family_clock";
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
