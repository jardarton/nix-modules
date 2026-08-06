{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkDefault
    mkIf
    mkOption
    types
    ;

  cfg = config.modules.nixos.mango;
in
{
  options.modules.nixos.mango = {
    enable = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = "Whether to enable Mango system integration.";
    };

    package = mkOption {
      type = types.package;
      description = "The Mango package used for the compositor session.";
    };
  };

  config = mkIf cfg.enable {
    programs.mango = {
      enable = true;
      inherit (cfg) package;
    };

    # Home Manager installs and configures the swaylock client separately.
    # NixOS must provide the matching PAM service for password unlocks.
    security.pam.services.swaylock = { };

    # Mango's NixOS module supplies the session entry and portal packages.
    # Keep these integration choices overrideable by consumers.
    programs.xwayland.enable = mkDefault true;
    xdg.portal = {
      enable = mkDefault true;
      wlr.enable = mkDefault true;
      xdgOpenUsePortal = mkDefault true;
    };
  };
}
