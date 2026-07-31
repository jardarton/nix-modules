{ config, ... }:
{
  reusableModules.home.i3 = ./i3/home.nix;
  flake.homeModules.i3 = config.reusableModules.home.i3;
}
