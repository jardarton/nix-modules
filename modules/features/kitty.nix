{
  flake.modules.homeManager.kitty = ./kitty/home.nix;

  # Export groups evaluated together by this flake's module checks.
  nixModules.checkCompositions.homeManager.graphical = [ "kitty" ];
}
