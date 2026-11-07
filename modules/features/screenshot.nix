{
  flake.modules.homeManager.screenshot =
    {
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ ./screenshot/home.nix ];
      modules.home.screenshot.enable = lib.mkDefault pkgs.stdenv.hostPlatform.isLinux;
    };

  # Export groups evaluated together by this flake's module checks.
  nixModules.checkCompositions.homeManager.graphical = [ "screenshot" ];
}
