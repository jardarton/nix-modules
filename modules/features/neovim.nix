{ lib, ... }:
{
  flake.modules.homeManager.neovim = {
    imports = [ ./neovim/home.nix ];
    modules.home.neovim.enable = lib.mkDefault true;
  };

  # Export groups evaluated together by this flake's module checks.
  nixModules.checkCompositions.homeManager.workstation = [ "neovim" ];
}
