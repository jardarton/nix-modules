{
  flake.modules.homeManager.presentation = ./presentation/home.nix;

  # Export groups evaluated together by this flake's module checks.
  nixModules.checkCompositions.homeManager.workstation = [ "presentation" ];
}
