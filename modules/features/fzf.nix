{ config, lib, ... }:
{
  # Two definitions rather than one imports list, so the feature module keeps
  # its place in the module order and only the helper is added.
  flake.modules.homeManager.fzf = lib.mkMerge [
    ./fzf/home.nix
    { imports = [ config.nixModules.stylixHelper ]; }
  ];

  # Export groups evaluated together by this flake's module checks.
  nixModules.checkCompositions.homeManager.workstation = [ "fzf" ];
}
