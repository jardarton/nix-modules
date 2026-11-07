{ config, lib, ... }:
let
  cfg = config.modules.home.hypr;
  inherit (lib) mkIf;
in
{
  services = {
    hyprsunset = mkIf cfg.hyprsunset {
      enable = true;
      settings.profile = [
        {
          time = "06:00";
          identity = true;
        }
        {
          time = "19:00";
          temperature = 2500;
        }
      ];
    };
  };
}
