{
  flake.modules.homeManager.media =
    {
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ ./media/home.nix ];
      modules.home.media.enable = lib.mkDefault pkgs.stdenv.hostPlatform.isLinux;
    };

  # Export groups evaluated together by this flake's module checks.
  nixModules.checkCompositions.homeManager.graphical = [ "media" ];
}
