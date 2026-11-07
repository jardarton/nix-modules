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
    // optionalAttrs (options ? stylix) {
      stylix.targets.vscode.profileNames = [ "default" ];
    }
  );
}
