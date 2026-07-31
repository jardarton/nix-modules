{ config, ... }:
{
  reusableModules.home.television = ./television/home.nix;
  flake.homeModules.television = config.reusableModules.home.television;
}
