{
  flake.modules.homeManager.tmux = ./tmux/home.nix;

  # Export groups evaluated together by this flake's module checks.
  nixModules.checkCompositions.homeManager.workstation = [ "tmux" ];
}
