{ lib, ... }:
{
  flake.modules.nixos.home-assistant = {
    imports = [ ./home-assistant/nixos.nix ];
    modules.nixos.home-assistant.enable = lib.mkDefault true;
  };
}
