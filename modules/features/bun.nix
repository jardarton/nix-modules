{ config, ... }:
{
  reusableModules.home.bun = ./bun/home.nix;
  flake.homeModules.bun = config.reusableModules.home.bun;
}
