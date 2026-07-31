{ config, ... }:
{
  reusableModules.home.waybar = ./waybar/home.nix;
  flake.homeModules.waybar = config.reusableModules.home.waybar;
}
