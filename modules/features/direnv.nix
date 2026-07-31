{ config, ... }:
{
  reusableModules.home.direnv = ./direnv/home.nix;
  flake.homeModules.direnv = config.reusableModules.home.direnv;
}
