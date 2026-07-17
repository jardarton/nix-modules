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
  flake.nixosModules = {
    base-packages = importApply ./base-packages.nix { localFlake = moduleFlake; };
    laptop-base = importApply ./laptop-base.nix { localFlake = moduleFlake; };
    bluetooth = importApply ./bluetooth.nix;
    stylix = importApply ./stylix.nix { localFlake = moduleFlake; };
    keyd = importApply ./keyd.nix { localFlake = moduleFlake; };
    kanata = importApply ./kanata { localFlake = moduleFlake; };
    fonts = importApply ./fonts.nix { localFlake = moduleFlake; };
    mango = importApply ./mango.nix { localFlake = moduleFlake; };
    home-assistant = importApply ./home-assistant { localFlake = moduleFlake; };
    oryx = importApply ./oryx.nix { localFlake = moduleFlake; };
    wifi = importApply ./wifi.nix { localFlake = moduleFlake; };
  };
}
