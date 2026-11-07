{ lib, ... }:
{
  flake.modules.nixos.home-assistant = {
    imports = [ ./home-assistant/nixos.nix ];
    modules.nixos.home-assistant.enable = lib.mkDefault true;
  };

  # Export groups evaluated together by this flake's module checks.
  nixModules.checkCompositions.nixos.server = [ "home-assistant" ];
}
