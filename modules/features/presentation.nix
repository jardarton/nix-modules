{ config, ... }:
{
  reusableModules.home.presentation = ./presentation/home.nix;
  flake.homeModules.presentation = config.reusableModules.home.presentation;
}
