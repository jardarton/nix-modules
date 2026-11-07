{
  flake.modules.homeManager.bat = ./bat/home.nix;

  # Export groups evaluated together by this flake's module checks.
  nixModules.checkCompositions.homeManager.workstation = [ "bat" ];
}
