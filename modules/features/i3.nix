{
  flake.modules.homeManager.i3 =
    {
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ ./i3/home.nix ];
      modules.home.i3.enable = lib.mkDefault pkgs.stdenv.hostPlatform.isLinux;
    };

  # Export groups evaluated together by this flake's module checks.
  nixModules.checkCompositions.homeManager.graphical = [ "i3" ];
}
