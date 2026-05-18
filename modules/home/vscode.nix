{ localFlake, ... }:
{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.home.vscode;
in
{

  options.modules.home.vscode = {
    enable = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = "enable vscode";
    };
  };

  config = mkIf cfg.enable {
    stylix.targets.vscode.profileNames = [ "default" ];
    programs.vscode = {
      enable = true;
      profiles = {
        default = {
          extensions = [
            pkgs.vscode-extensions.bbenoist.nix
            pkgs.vscode-extensions.vscodevim.vim
          ];
        };
      };
    };
  };
}
