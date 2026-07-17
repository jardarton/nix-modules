{ localFlake, ... }:
{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.home.bitwarden;
in
{

  options.modules.home.bitwarden = {
    enable = mkOption {
      type = types.bool;
      default = true;
      example = true;
      description = "enable bitwarden";
    };
  };

  config = mkIf cfg.enable {

    home.packages = [
      pkgs.pinentry-tty
    ];

    programs.rbw = {
      enable = true;
      #TODO
      # settings = {
      #   base_url = "https://vault.bitwarden.eu";
      #   lock_timout = 8888;
      # };
    };

    home.file.".local/scripts/rbw-copy" = {
      executable = true;
      text = ''
        ITEM="$(rbw list | fsel --dmenu)" 
        rbw get $ITEM | wl-copy
      '';
    };
  };
}
