{
  flake.modules.homeManager.eza = ./eza/home.nix;

  # Export groups evaluated together by this flake's module checks.
  nixModules.checkCompositions.homeManager.workstation = [ "eza" ];
}
