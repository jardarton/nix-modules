{ lib, ... }:
{
  flake.modules.nixos.laptop-base = {
    imports = [ ./laptop-base/nixos.nix ];
    modules.nixos.laptop-base.enable = lib.mkDefault true;
  };

  # Export groups evaluated together by this flake's module checks.
  nixModules.checkCompositions.nixos."laptop-kanata" = [ "laptop-base" ];
  nixModules.checkCompositions.nixos."laptop-keyd" = [ "laptop-base" ];
}
