{ localFlake, ... }:
{ config
, pkgs
, lib
, ...
}:
with lib;
let
  cfg = config.modules.home.fonts;
in
{

  options.modules.home.fonts = {
    enable = mkOption {
      type = types.bool;
      default = true;
      example = true;
      description = "enable fonts";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      monaspace
      nerd-fonts.hack
      nerd-fonts.caskaydia-cove
      nerd-fonts.monaspace
      nerd-fonts.symbols-only
    ];

    fonts.fontconfig.enable = true;
  };
}
