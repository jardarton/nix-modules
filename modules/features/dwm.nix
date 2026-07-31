{ config, ... }:
{
  reusableModules.home.dwm = ./dwm/home.nix;
  flake.homeModules.dwm = config.reusableModules.home.dwm;
}
