{
  flake.modules.nixos.wifi = ./wifi/nixos.nix;

  # Export groups evaluated together by this flake's module checks.
  nixModules.checkCompositions.nixos."laptop-kanata" = [ "wifi" ];
}
