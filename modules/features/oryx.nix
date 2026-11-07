{
  flake.modules.nixos.oryx = ./oryx/nixos.nix;

  # Export groups evaluated together by this flake's module checks.
  nixModules.checkCompositions.nixos."laptop-kanata" = [ "oryx" ];
}
