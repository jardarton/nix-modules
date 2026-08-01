{ lib, ... }:
{
  flake.modules.homeManager.neovim = {
    imports = [ ./neovim/home.nix ];
    modules.home.neovim.enable = lib.mkDefault true;
  };
}
