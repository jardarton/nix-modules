{ config, ... }:
{
  reusableModules.nixos.home-assistant = ./home-assistant/nixos.nix;
  flake.nixosModules.home-assistant = config.reusableModules.nixos.home-assistant;
}
