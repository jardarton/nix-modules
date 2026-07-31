{ config, ... }:
{
  reusableModules.home.neovim = ./neovim/home.nix;
  flake.homeModules.neovim = config.reusableModules.home.neovim;
}
