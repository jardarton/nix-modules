{ config, ... }:
{
  reusableModules.home.catsvim = ./catsvim/home.nix;
  flake.homeModules.catsvim = config.reusableModules.home.catsvim;
}
