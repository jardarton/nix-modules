{ lib, ... }:
{
  flake.modules.nixos.keyd = {
    imports = [ ./keyd/nixos.nix ];
    modules.nixos.keyd.enable = lib.mkDefault true;
  };
}
