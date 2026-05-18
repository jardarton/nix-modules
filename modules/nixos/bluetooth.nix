{ ... }:
{ lib, ... }:
{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = lib.mkDefault false;
    settings.General = {
      Experimental = true;
    };
  };
}
