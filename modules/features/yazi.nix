{
  flake.modules.homeManager.yazi = ./yazi/home.nix;

  # Export groups evaluated together by this flake's module checks.
  nixModules.checkCompositions.homeManager.workstation = [ "yazi" ];
}
