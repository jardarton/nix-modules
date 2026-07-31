{ config, ... }:
{
  reusableModules.nixos.kanata = ./kanata/nixos.nix;
  flake.nixosModules.kanata = config.reusableModules.nixos.kanata;
}
