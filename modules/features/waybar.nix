{ config, ... }:
{
  flake.modules.homeManager.waybar =
    {
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        ./waybar/home.nix
        config.nixModules.stylixHelper
      ];
      modules.home.waybar.enable = lib.mkDefault pkgs.stdenv.hostPlatform.isLinux;
    };

  # Export groups evaluated together by this flake's module checks.
  nixModules.checkCompositions.homeManager.graphical = [ "waybar" ];
}
