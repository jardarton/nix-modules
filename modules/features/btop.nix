{ config, ... }:
{
  reusableModules.home.btop = ./btop/home.nix;
  flake.homeModules.btop = config.reusableModules.home.btop;
}
