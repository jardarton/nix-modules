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
}
