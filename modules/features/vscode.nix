{ lib, ... }:
{
  flake.modules.homeManager.vscode = {
    imports = [ ./vscode/home.nix ];
    modules.home.vscode.enable = lib.mkDefault true;
  };

  # Export groups evaluated together by this flake's module checks.
  nixModules.checkCompositions.homeManager.graphical = [ "vscode" ];
}
