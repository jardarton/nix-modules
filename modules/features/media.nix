{ config, ... }:
{
  reusableModules.home.media = ./media/home.nix;
  flake.homeModules.media = config.reusableModules.home.media;
}
