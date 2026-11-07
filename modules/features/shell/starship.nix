{ lib, config, ... }:
let
  inherit (lib) mkIf mkOption types;
  cfg = config.modules.home.starship;
in
{

  options.modules.home.starship = {
    enable = mkOption {
      type = types.bool;
      default = true;
      example = true;
      description = "enable starship";
    };
  };

  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
