{ localFlake, ... }:
{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.home.screenshot;
in
{

  options.modules.home.screenshot = {
    enable = mkOption {
      type = types.bool;
      default = true;
      example = true;
      description = "enable screenshot";
    };
  };

  config = mkIf cfg.enable {

    home.packages = [
      pkgs.slurp
      pkgs.grim
      pkgs.wl-clipboard
    ];

    home.file.".local/scripts/screenshot-area-clipboard" = {
      executable = true;
      text = ''
        grim -g "$(slurp)" - | wl-copy
      '';
    };

    home.file.".local/scripts/screenshot-area-file" = {
      executable = true;
      text = ''
        grim -g "$(slurp)" ~/Screenshots/$(date +'%s_grim.png')
      '';
    };
  };
}
