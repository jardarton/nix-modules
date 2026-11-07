{
  flake.modules.homeManager.cli-tools = ./cli-tools/home.nix;

  # Export groups evaluated together by this flake's module checks.
  nixModules.checkCompositions.homeManager.workstation = [ "cli-tools" ];
}
