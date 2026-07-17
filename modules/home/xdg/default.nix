_:
{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.home.xdg;
in
{
  imports = [
  ];

  options.modules.home.xdg = {
    enable = mkOption {
      type = types.bool;
      default = true;
      example = true;
      description = "enable xdg config";
    };
  };

  config = mkIf cfg.enable {
    xdg = {
      enable = true;
      dataHome = "${config.home.homeDirectory}/.local/share";
      mime.enable = true;
      mimeApps.enable = true;
      portal = {
        enable = true;
        config = {
          common = {
            default = [
              "gtk"
            ];
          };
          mango = {
            default = [
              "wlr"
              "gtk"
            ];
            "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
          };
          hyperland = {
            default = [
              "hyprland"
              "gtk"
            ];
          };
        };
        extraPortals = [
          pkgs.xdg-desktop-portal-wlr
          pkgs.xdg-desktop-portal-gtk
        ];
      };
      userDirs = {
        enable = true;
        createDirectories = true;
        desktop = null;
        publicShare = null;
        templates = null;
        music = null;

        extraConfig = {
          screenShotDir = "${config.home.homeDirectory}/Screenshots";
        };
      };
    };
  };
}
