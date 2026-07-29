_:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.home.presentation;
in
{
  options.modules.home.presentation = {
    enable = lib.mkEnableOption "terminal presentation tools" // {
      default = true;
    };

    asciinemaPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.asciinema;
      defaultText = lib.literalExpression "pkgs.asciinema";
      description = "The asciinema package to install.";
    };

    presentermPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.presenterm;
      defaultText = lib.literalExpression "pkgs.presenterm";
      description = "The Presenterm package to install.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      cfg.asciinemaPackage
      cfg.presentermPackage
    ];
  };
}
