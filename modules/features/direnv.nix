{
  flake.modules.homeManager.direnv = ./direnv/home.nix;

  # Export groups evaluated together by this flake's module checks.
  nixModules.checkCompositions.homeManager.workstation = [ "direnv" ];
}
