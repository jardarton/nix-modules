{ config, ... }:
{
  reusableModules.home.bat = ./bat/home.nix;
  flake.homeModules.bat = config.reusableModules.home.bat;
}
