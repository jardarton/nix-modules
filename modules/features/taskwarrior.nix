{ config, ... }:
{
  reusableModules.home.taskwarrior = ./taskwarrior/home.nix;
  flake.homeModules.taskwarrior = config.reusableModules.home.taskwarrior;
}
