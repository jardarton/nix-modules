{ config, ... }:
{
  reusableModules.home = {
    zsh = ./shell/zsh.nix;
    starship = ./shell/starship.nix;
  };

  flake.homeModules = {
    zsh = config.reusableModules.home.zsh;
    starship = config.reusableModules.home.starship;
  };
}
