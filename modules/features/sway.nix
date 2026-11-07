{
  flake.modules.homeManager.sway =
    {
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ ./sway/home.nix ];
      modules.home.sway.enable = lib.mkDefault pkgs.stdenv.hostPlatform.isLinux;
    };

  # Export groups evaluated together by this flake's module checks.
  nixModules.checkCompositions.homeManager.graphical = [ "sway" ];
}
