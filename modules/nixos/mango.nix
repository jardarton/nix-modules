{ localFlake }:
{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.nixos.mango;
in
{
  options.modules.nixos.mango = {
    enable = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = "enable mango vm";
    };
  };

  imports = [
    localFlake.inputs.mango.nixosModules.mango
  ];

  config = mkIf cfg.enable {
    programs.mango.enable = true;

    environment.systemPackages = [
      pkgs.wlr-randr
      pkgs.pamixer
      pkgs.brightnessctl
    ];

    programs.xwayland.enable = mkDefault true;
    xdg.portal = {
      enable = mkDefault true;
      wlr.enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-wlr
        pkgs.xdg-desktop-portal-gtk
      ];
      config = {
        mango = {
          default = [
            "gtk"
          ];
          "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
        };
      };
      config.common.default = [ "wlr" ];
      xdgOpenUsePortal = mkDefault true;
    };
  };
}
