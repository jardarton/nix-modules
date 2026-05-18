{ config, lib, ... }:
let
  cfg = config.modules.home.hypr;
in
with lib;
{
  services = {
    hyprsunset = mkIf cfg.hyprsunset {
      enable = true;
      transitions = {
        sunrise = {
          calendar = "*-*-* 06:00:00";
          requests = [
            [
              "temperature"
              "2500"
            ]
          ];
        };
        sunset = {
          calendar = "*-*-* 19:00:00";
          requests = [
            [
              "temperature"
              "6500"
            ]
            [ "gamma 100" ]
          ];
        };
      };
    };
  };
}
