{ lib, ... }:
{
  flake.modules.homeManager.vscode = {
    imports = [ ./vscode/home.nix ];
    modules.home.vscode.enable = lib.mkDefault true;
  };
}
