{
  flake-parts-lib,
  self,
  inputs,
  ...
}:
let
  inherit (flake-parts-lib) importApply;
  moduleFlake = inputs.nix-modules or self;
in
{
  flake.homeModules = {

    default = importApply ./base-home.nix { localFlake = moduleFlake; };
  };
}
