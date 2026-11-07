{ lib, ... }:
{
  flake.modules.nixos.keyd = {
    imports = [ ./keyd/nixos.nix ];
    modules.nixos.keyd.enable = lib.mkDefault true;
  };

  # Export groups evaluated together by this flake's module checks.
  nixModules.checkCompositions.nixos."laptop-keyd" = [ "keyd" ];
}
