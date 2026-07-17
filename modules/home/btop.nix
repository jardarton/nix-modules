{ localFlake, ... }:
{ config
, pkgs
, lib
, inputs
, ...
}:
with lib;
let
  cfg = config.modules.home.btop;
in
{

  options.modules.home.btop = {
    enable = mkOption {
      type = types.bool;
      default = true;
      example = true;
      description = "enable btop";
    };
  };

  config = mkIf cfg.enable {
    programs.btop = {
      enable = true;
      settings = {
        vim_keys = true;
        rounded_corners = true;
        cpu_bottom = true;
        show_uptime = true;
        temp_scale = "celsius";
        swap_disk = true;
        show_battery = true;
        show_battery_watts = true;
      };
    };
  };
}
