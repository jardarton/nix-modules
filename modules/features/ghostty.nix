{ config, ... }:
{
  reusableModules.home.ghostty = ./ghostty/home.nix;
  flake.homeModules.ghostty = config.reusableModules.home.ghostty;
}
