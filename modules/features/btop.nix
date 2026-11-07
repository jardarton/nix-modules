{
  flake.modules.homeManager.btop = ./btop/home.nix;

  # Export groups evaluated together by this flake's module checks.
  nixModules.checkCompositions.homeManager.workstation = [ "btop" ];
}
