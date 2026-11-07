{
  flake.modules.homeManager.bun = ./bun/home.nix;

  # Export groups evaluated together by this flake's module checks.
  nixModules.checkCompositions.homeManager.workstation = [ "bun" ];
}
