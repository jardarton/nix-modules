{ config, ... }:
{
  reusableModules.nixos.oryx = ./oryx/nixos.nix;
  flake.nixosModules.oryx = config.reusableModules.nixos.oryx;
}
