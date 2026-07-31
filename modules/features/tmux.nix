{ config, ... }:
{
  reusableModules.home.tmux = ./tmux/home.nix;
  flake.homeModules.tmux = config.reusableModules.home.tmux;
}
