{ config, ... }:
{
  reusableModules.nixos.wifi = ./wifi/nixos.nix;
  flake.nixosModules.wifi = config.reusableModules.nixos.wifi;
}
