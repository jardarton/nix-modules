{ config, ... }:
{
  reusableModules.home.aerospace = ./aerospace/home.nix;
  flake.homeModules.aerospace = config.reusableModules.home.aerospace;
}
