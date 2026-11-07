{ config, lib, ... }:
{
  # Two definitions rather than one imports list, so the feature module keeps
  # its place in the module order and only the helper is added.
  flake.modules.homeManager.fzf = lib.mkMerge [
    ./fzf/home.nix
    { imports = [ config.nixModules.stylixHelper ]; }
  ];
}
