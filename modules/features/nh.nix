{
  imports = [ ./nh/checks.nix ];

  flake.modules.homeManager.nh = ./nh/home.nix;
}
