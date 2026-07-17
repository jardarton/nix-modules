{ ... }:
{ config
, lib
, ...
}:
with lib;
let
  cfg = config.modules.nixos.kanata;
in
{
  options.modules.nixos.kanata = {
    enable = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = "enable kanata for built in keyboard";
    };
  };

  imports = [
  ];

  config = mkIf cfg.enable {
    services.kanata = {
      enable = true;
      keyboards = {
        laptop = {
          configFile = ./kanata.kbd;
        };
      };
    };
  };
}
