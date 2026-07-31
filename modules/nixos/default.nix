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
  flake.nixosModules.home-assistant = importApply ./home-assistant { localFlake = moduleFlake; };
}
