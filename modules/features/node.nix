{
  flake.modules.homeManager.node = ./node/home.nix;

  # Export groups evaluated together by this flake's module checks.
  nixModules.checkCompositions.homeManager.workstation = [ "node" ];
}
