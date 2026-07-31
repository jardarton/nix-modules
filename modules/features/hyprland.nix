{ config, ... }:
{
  reusableModules.home.hyprland = ./hyprland/home.nix;
  flake.homeModules.hyprland = config.reusableModules.home.hyprland;
}
