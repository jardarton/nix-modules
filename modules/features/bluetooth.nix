{ config, ... }:
{
  reusableModules.nixos.bluetooth = ./bluetooth/nixos.nix;
  flake.nixosModules.bluetooth = config.reusableModules.nixos.bluetooth;
}
