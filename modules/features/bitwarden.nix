{ config, ... }:
{
  reusableModules.home.bitwarden = ./bitwarden/home.nix;
  flake.homeModules.bitwarden = config.reusableModules.home.bitwarden;
}
