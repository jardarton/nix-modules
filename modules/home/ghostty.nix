{ localFlake, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.home.ghostty;
in
{

  options.modules.home.ghostty = {
    enable = mkOption {
      type = types.bool;
      default = false;
      example = false;
      description = "enable ghostty";
    };
    package = mkOption {
      type = types.package;
      default = pkgs.ghostty;
    };
    custom-shader = mkOption {
      type = with types; listOf str;
      example = [ "shader.glsl" ];
      default = [ ];
    };
    opacity = mkOption {
      type = types.float;
      example = 1.0;
      default = 1.0;
    };
  };

  config = mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      package = cfg.package;
      enableZshIntegration = true;
      settings = {
        font-feature = [
          "ss01"
          "ss02"
          "ss03"
          "ss04"
          "ss05"
          "ss06"
          "ss07"
          "ss09"
        ];
        font-thicken = true;

        copy-on-select = "clipboard";
        background-opacity-cells = true;
        #cursor-style = block
        mouse-hide-while-typing = true;
        macos-titlebar-proxy-icon = "hidden";
        macos-titlebar-style = "hidden";
        title = " ";
        macos-non-native-fullscreen = true;
        window-decoration = true;
        background-opacity = cfg.opacity;
        background-blur = true;
        custom-shader = cfg.custom-shader;
      };
    };

    # home.file.".config/ghostty/themes/cyberdream".text = ''
    #   # cyberdream theme for ghostty
    #   palette = 0=#16181a
    #   palette = 1=#ff6e5e
    #   palette = 2=#5eff6c
    #   palette = 3=#f1ff5e
    #   palette = 4=#5ea1ff
    #   palette = 5=#bd5eff
    #   palette = 6=#5ef1ff
    #   palette = 7=#ffffff
    #   palette = 8=#3c4048
    #   palette = 9=#ff6e5e
    #   palette = 10=#5eff6c
    #   palette = 11=#f1ff5e
    #   palette = 12=#5ea1ff
    #   palette = 13=#bd5eff
    #   palette = 14=#5ef1ff
    #   palette = 15=#ffffff
    #
    #   background = #16181a
    #   foreground = #ffffff
    #   cursor-color = #ffffff
    #   selection-background = #3c4048
    #   selection-foreground = #ffffff
    # '';
    # programs.ghostty = {
    #   enable = true;
    #   installVimSyntax = true;
    #   enableZshIntegration = true;
    #   settings = {
    #     theme = "cyberdream";
    #     #theme = catppuccin-mocha
    #     font-family = "Monaspace Krypton";
    #     font-feature = "ss01,ss02,ss03,ss04,ss05,ss06,ss07,ss09,liga";
    #     font-thicken = true;
    #     copy-on-select = "clipboard";
    #     #cursor-style = block;
    #     mouse-hide-while-typing = true;
    #     macos-titlebar-proxy-icon = "hidden";
    #     macos-titlebar-style = "hidden";
    #     title = " ";
    #     macos-non-native-fullscreen = true;
    #     window-decoration = true;
    #     background-opacity = 0.55;
    #     background-blur = true;
    #
    #   };
    #   themes = {
    #     cyberdream = {
    #       palette = [
    #         "0=#16181a"
    #         "1=#ff6e5e"
    #         "2=#5eff6c"
    #         "3=#f1ff5e"
    #         "4=#5ea1ff"
    #         "5=#bd5eff"
    #         "6=#5ef1ff"
    #         "7=#ffffff"
    #         "8=#3c4048"
    #         "9=#ff6e5e"
    #         "10=#5eff6c"
    #         "11=#f1ff5e"
    #         "12=#5ea1ff"
    #         "13=#bd5eff"
    #         "14=#5ef1ff"
    #         "15=#ffffff"
    #
    #       ];
    #       background = "#16181a";
    #       foreground = "#ffffff";
    #       cursor-color = "#ffffff";
    #       selection-background = "#3c4048";
    #       selection-foreground = "#ffffff";
    #     };
    #   };
    # };
  };
}
