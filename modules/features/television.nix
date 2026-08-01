{ lib, ... }:
{
  flake.modules.homeManager.television = {
    imports = [ ./television/home.nix ];
    modules.home.television.enable = lib.mkDefault true;
  };
}
