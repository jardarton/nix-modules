{ config, ... }:
{
  reusableModules.nixos.keyd = ./keyd/nixos.nix;
  flake.nixosModules.keyd = config.reusableModules.nixos.keyd;
}
