{ config, ... }:
{
  reusableModules.home.screenshot = ./screenshot/home.nix;
  flake.homeModules.screenshot = config.reusableModules.home.screenshot;
}
