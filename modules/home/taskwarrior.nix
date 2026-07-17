{ localFlake, ... }:
{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.home.taskwarrior;
in
{

  options.modules.home.taskwarrior = {
    enable = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = "enable taskwarrior";
    };
  };

  config = mkIf cfg.enable {

    home.packages = [
      pkgs.taskwarrior-tui
    ];

    programs.taskwarrior = {
      enable = true;
      package = pkgs.taskwarrior2;
    };
    home.shellAliases.tw = lib.getExe pkgs.taskwarrior2;
  };
}
