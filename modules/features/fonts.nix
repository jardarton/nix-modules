{
  flake.modules = {
    homeManager.fonts = ./fonts/home.nix;
    nixos.fonts = ./fonts/nixos.nix;
  };

  # Export groups evaluated together by this flake's module checks.
  nixModules.checkCompositions.homeManager.graphical = [ "fonts" ];
  nixModules.checkCompositions.nixos."laptop-kanata" = [ "fonts" ];
  nixModules.checkCompositions.nixos."laptop-keyd" = [ "fonts" ];
}
