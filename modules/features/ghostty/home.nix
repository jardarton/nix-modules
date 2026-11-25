{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkOption types;
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
      inherit (cfg) package;
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
        inherit (cfg) custom-shader;
      };
    };
  };
}
