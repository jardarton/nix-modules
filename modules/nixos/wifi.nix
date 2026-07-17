_:
{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.impala
  ];

  networking.wireless = {
    iwd.enable = true;
  };

}
