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
    firefox = importApply ./firefox { localFlake = moduleFlake; };
    reverse-engineering = importApply ./reverse-engineering.nix { localFlake = moduleFlake; };
    catsvim = importApply ./catsvim { localFlake = moduleFlake; };
    ai = importApply ./ai { localFlake = moduleFlake; };
    herdr = importApply ./herdr.nix { localFlake = moduleFlake; };
  };
}
