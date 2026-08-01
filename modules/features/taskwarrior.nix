{ lib, ... }:
{
  flake.modules.homeManager.taskwarrior = {
    imports = [ ./taskwarrior/home.nix ];
    modules.home.taskwarrior.enable = lib.mkDefault true;
  };
}
