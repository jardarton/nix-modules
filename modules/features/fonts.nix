{ config, ... }:
{
  reusableModules = {
    home.fonts = ./fonts/home.nix;
    nixos.fonts = ./fonts/nixos.nix;
  };

  flake = {
    homeModules.fonts = config.reusableModules.home.fonts;
    nixosModules.fonts = config.reusableModules.nixos.fonts;
  };
}
