{ config, ... }:
{
  reusableModules.home.nh = ./nh/home.nix;
  flake.homeModules.nh = config.reusableModules.home.nh;
}
