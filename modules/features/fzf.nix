{ config, ... }:
{
  reusableModules.home.fzf = ./fzf/home.nix;
  flake.homeModules.fzf = config.reusableModules.home.fzf;
}
