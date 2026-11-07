{
  flake.modules.homeManager = {
    zsh = ./shell/zsh.nix;
    starship = ./shell/starship.nix;
  };

  # Export groups evaluated together by this flake's module checks.
  nixModules.checkCompositions.homeManager.workstation = [
    "starship"
    "zsh"
  ];
}
