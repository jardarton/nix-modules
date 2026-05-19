{ localFlake, ... }:
{ config
, lib
, pkgs
, ...
}:
with lib;
let
  cfg = config.modules.home.nh;
in
{
  options.modules.home.nh = {
    enable = mkOption {
      type = types.bool;
      default = true;
      example = true;
      description = "enable nh, yet another Nix CLI helper";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.nh;
      defaultText = literalExpression "pkgs.nh";
      description = "The nh package to install.";
    };

    flake = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "/home/user/dotfiles";
      description = ''
        Flake reference exported as NH_FLAKE when set.

        nh uses NH_FLAKE as the default flake for commands such as
        `nh os switch` and `nh home switch`.
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = (cfg.flake != null) -> !(hasSuffix ".nix" cfg.flake);
        message = "modules.home.nh.flake must be a flake reference or directory, not a nix file";
      }
    ];

    home.packages = [ cfg.package ];

    home.sessionVariables = mkIf (cfg.flake != null) {
      NH_FLAKE = cfg.flake;
    };
  };
}
