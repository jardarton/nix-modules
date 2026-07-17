{ localFlake, ... }:
{ config
, lib
, ...
}:
with lib;
let
  cfg = config.modules.home.direnv;
in
{

  options.modules.home.direnv = {
    enable = mkOption {
      type = types.bool;
      default = true;
      example = true;
      description = "enable direnv";
    };
  };

  config = mkIf cfg.enable {
    programs = {
      direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };
    };
  };
}
