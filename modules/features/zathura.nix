{
  flake.modules.homeManager.zathura =
    {
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ ./zathura/home.nix ];
      modules.home.zathura.enable = lib.mkDefault pkgs.stdenv.hostPlatform.isLinux;
    };

  # Export groups evaluated together by this flake's module checks.
  nixModules.checkCompositions.homeManager.graphical = [ "zathura" ];
}
