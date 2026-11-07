{
  flake.modules.homeManager.default = ./base-home/home.nix;

  # Export groups evaluated together by this flake's module checks.
  nixModules.checkCompositions.homeManager.workstation = [ "default" ];
}
