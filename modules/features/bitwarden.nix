{
  flake.modules.homeManager.bitwarden = ./bitwarden/home.nix;

  # Export groups evaluated together by this flake's module checks.
  nixModules.checkCompositions.homeManager.graphical = [ "bitwarden" ];
}
