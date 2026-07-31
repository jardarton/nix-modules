{ config, ... }:
{
  reusableModules.home.zathura = ./zathura/home.nix;
  flake.homeModules.zathura = config.reusableModules.home.zathura;
}
