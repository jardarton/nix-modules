{
  pkgs,
  config,
  lib,
  options,
  ...
}:
let
  inherit (lib)
    mkIf
    mkOption
    optionalAttrs
    types
    ;
  cfg = config.modules.home.vscode;
  stylix = import ../stylix/lib.nix { inherit config options; };
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
