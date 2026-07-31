{ config, ... }:
{
  reusableModules.home.kitty = ./kitty/home.nix;
  flake.homeModules.kitty = config.reusableModules.home.kitty;
}
