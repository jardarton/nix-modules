{ config, ... }:
{
  reusableModules.home.default = ./base-home/home.nix;
  flake.homeModules.default = config.reusableModules.home.default;
}
