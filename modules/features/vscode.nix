{ config, ... }:
{
  reusableModules.home.vscode = ./vscode/home.nix;
  flake.homeModules.vscode = config.reusableModules.home.vscode;
}
