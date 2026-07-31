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
    package = mkOption {
      type = types.package;
      description = "Mango package to use.";
    };
  };

  config = mkIf cfg.enable {
    programs.mango = {
      enable = true;
      inherit (cfg) package;
    };

    environment.systemPackages = [
      pkgs.wlr-randr
      pkgs.pamixer
      pkgs.brightnessctl
    ];

    # Home Manager's swaylock module only installs/configures the client; the
    # matching PAM service must be declared by NixOS for password unlocks.
    security.pam.services.swaylock = { };

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
