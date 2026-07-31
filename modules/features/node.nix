{ config, ... }:
{
  reusableModules.home.node = ./node/home.nix;
  flake.homeModules.node = config.reusableModules.home.node;
}
