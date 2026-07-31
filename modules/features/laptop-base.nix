{ config, ... }:
{
  reusableModules.nixos.laptop-base = ./laptop-base/nixos.nix;
  flake.nixosModules.laptop-base = config.reusableModules.nixos.laptop-base;
}
