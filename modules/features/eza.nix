{ config, ... }:
{
  reusableModules.home.eza = ./eza/home.nix;
  flake.homeModules.eza = config.reusableModules.home.eza;
}
