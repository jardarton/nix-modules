{ localFlake, ... }:
{
  pkgs,
  config,
  lib,
  options,
  ...
}:
with lib;
let
  cfg = config.modules.home.vscode;
  stylix = import ./lib/stylix.nix { inherit config options; };
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

  config = mkIf cfg.enable (
    {
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
    }
    // optionalAttrs stylix.hasStylix {
      stylix.targets.vscode.profileNames = [ "default" ];
    }
  );
}
