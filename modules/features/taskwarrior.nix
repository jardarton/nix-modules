{ lib, ... }:
{
  flake.modules.homeManager.taskwarrior = {
    imports = [ ./taskwarrior/home.nix ];
    modules.home.taskwarrior.enable = lib.mkDefault true;
  };

  # Export groups evaluated together by this flake's module checks.
  nixModules.checkCompositions.homeManager.workstation = [ "taskwarrior" ];
}
