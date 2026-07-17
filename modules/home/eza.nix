{ localFlake, ... }:
{ config
, pkgs
, inputs
, lib
, ...
}:
with lib;
let
  cfg = config.modules.home.eza;
in
{

  options.modules.home.eza = {
    enable = mkOption {
      type = types.bool;
      default = true;
      example = true;
      description = "enable eza";
    };
  };

  config = mkIf cfg.enable {
    programs.eza = {
      enable = true;
      enableZshIntegration = true;
    };

    home.shellAliases = {
      eza = "eza -l --icons=always --color=always";
      l = "eza --color=always --color-scale=all --color-scale-mode=gradient --icons=always --group-directories-first";
      ll = "eza --color=always --color-scale=all --color-scale-mode=gradient --icons=always --group-directories-first -l --git -h";
      la = "eza --color=always --color-scale=all --color-scale-mode=gradient --icons=always --group-directories-first -a";
      lla = "eza --color=always --color-scale=all --color-scale-mode=gradient --icons=always --group-directories-first -a -l --git -h";
    };
  };
}
