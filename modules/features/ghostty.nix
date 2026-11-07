{
  flake.modules.homeManager.ghostty =
    {
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ ./ghostty/home.nix ];
      modules.home.ghostty.enable = lib.mkDefault pkgs.stdenv.hostPlatform.isLinux;
    };

  # Export groups evaluated together by this flake's module checks.
  nixModules.checkCompositions.homeManager.graphical = [ "ghostty" ];
}
