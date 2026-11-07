{
  flake.modules.homeManager.hyprland =
    {
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ ./hyprland/home.nix ];
      modules.home.hypr.enable = lib.mkDefault pkgs.stdenv.hostPlatform.isLinux;
    };

  # Export groups evaluated together by this flake's module checks.
  nixModules.checkCompositions.homeManager.graphical = [ "hyprland" ];
}
