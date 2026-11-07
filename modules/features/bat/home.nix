{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkOption types;
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
