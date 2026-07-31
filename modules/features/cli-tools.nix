{ config, ... }:
{
  reusableModules.home.cli-tools = ./cli-tools/home.nix;
  flake.homeModules.cli-tools = config.reusableModules.home.cli-tools;
}
