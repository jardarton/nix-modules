{ config, ... }:
{
  reusableModules.home.sway = ./sway/home.nix;
  flake.homeModules.sway = config.reusableModules.home.sway;
}
