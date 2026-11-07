{ lib, ... }:
{
  flake.modules.nixos.kanata = {
    imports = [ ./kanata/nixos.nix ];
    modules.nixos.kanata.enable = lib.mkDefault true;
  };

  # Export groups evaluated together by this flake's module checks.
  nixModules.checkCompositions.nixos."laptop-kanata" = [ "kanata" ];
}
