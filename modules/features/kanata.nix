{ lib, ... }:
{
  flake.modules.nixos.kanata = {
    imports = [ ./kanata/nixos.nix ];
    modules.nixos.kanata.enable = lib.mkDefault true;
  };
}
