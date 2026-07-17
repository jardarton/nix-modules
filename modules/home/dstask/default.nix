_:
{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.home.dstask;
in

{

  options.modules.home.dstask = {
    enable = mkOption {
      type = types.bool;
      default = true;
      example = true;
      description = "enable bat";
    };
    username = mkOption {
      type = types.str;
      default = "user";
      example = "joe";
      description = "user to run notfy service as";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      dstask
      curl
      git
      jq
      cron
    ];

    programs.zsh.initContent = ''
      source <(dstask zsh-completion)
    '';

    home.file.".local/scripts/update-tasks-notify" = {
      executable = true;
      text = ''
        ▎   #!/usr/bin/env bash
        ▎   ${pkgs.dstask}/bin/dstask git pull
        ▎   curl -H "X-Title: Ting å fikse" -d "$(${pkgs.dstask}/bin/dstask next | jq '.[].summary' | cut -d '"' -f 2)" ntfy/jardar
      '';
    };
  };
}
