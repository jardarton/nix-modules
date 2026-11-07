{
  flake.modules.homeManager.xdg =
    {
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ ./xdg/home.nix ];
      modules.home.xdg.enable = lib.mkDefault pkgs.stdenv.hostPlatform.isLinux;
    };

  # Export groups evaluated together by this flake's module checks.
  nixModules.checkCompositions.homeManager.graphical = [ "xdg" ];
}
