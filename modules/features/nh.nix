{
  imports = [ ./nh/checks.nix ];

  flake.modules.homeManager.nh = ./nh/home.nix;

  # Export groups evaluated together by this flake's module checks.
  nixModules.checkCompositions.homeManager.workstation = [ "nh" ];
}
