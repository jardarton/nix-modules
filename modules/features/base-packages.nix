{
  flake.modules.nixos.base-packages = ./base-packages/nixos.nix;

  # Export groups evaluated together by this flake's module checks.
  nixModules.checkCompositions.nixos."laptop-kanata" = [ "base-packages" ];
  nixModules.checkCompositions.nixos."laptop-keyd" = [ "base-packages" ];
  nixModules.checkCompositions.nixos.server = [ "base-packages" ];
}
