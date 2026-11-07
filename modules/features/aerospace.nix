{ config, ... }:
{
  flake.modules.homeManager.aerospace =
    {
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        ./aerospace/home.nix
        config.nixModules.stylixHelper
      ];
      modules.home.aerospace.enable = lib.mkDefault pkgs.stdenv.hostPlatform.isDarwin;
    };

  # Export groups evaluated together by this flake's module checks.
  nixModules.checkCompositions.homeManager.graphical = [ "aerospace" ];
}
