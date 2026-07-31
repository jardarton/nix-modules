{ config, ... }:
{
  reusableModules.home.yazi = ./yazi/home.nix;
  flake.homeModules.yazi = config.reusableModules.home.yazi;
}
