{ config, ... }:
{
  reusableModules.home.dstask = ./dstask/home.nix;
  flake.homeModules.dstask = config.reusableModules.home.dstask;
}
