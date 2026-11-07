{ lib, ... }:
{
  flake.modules.homeManager.television = {
    imports = [ ./television/home.nix ];
    modules.home.television.enable = lib.mkDefault true;
  };

  # Export groups evaluated together by this flake's module checks.
  nixModules.checkCompositions.homeManager.workstation = [ "television" ];
}
