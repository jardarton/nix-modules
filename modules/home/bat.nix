{ localFlake, ... }:
{ config
, pkgs
, inputs
, lib
, ...
}:
with lib;
let
  cfg = config.modules.home.bat;
in
{

  options.modules.home.bat = {
    enable = mkOption {
      type = types.bool;
      default = true;
      example = true;
      description = "enable bat";
    };
  };

  config = mkIf cfg.enable {
    programs.bat = {
      enable = true;
    };
  };
}
