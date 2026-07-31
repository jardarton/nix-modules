{ config, ... }:
{
  reusableModules.nixos.base-packages = ./base-packages/nixos.nix;
  flake.nixosModules.base-packages = config.reusableModules.nixos.base-packages;
}
