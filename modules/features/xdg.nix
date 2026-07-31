{ config, ... }:
{
  reusableModules.home.xdg = ./xdg/home.nix;
  flake.homeModules.xdg = config.reusableModules.home.xdg;
}
