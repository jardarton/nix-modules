{ lib, ... }:
{
  flake.modules.nixos.laptop-base = {
    imports = [ ./laptop-base/nixos.nix ];
    modules.nixos.laptop-base.enable = lib.mkDefault true;
  };
}
