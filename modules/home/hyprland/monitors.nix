{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib;
{
  wayland.windowManager.hyprland = {
    settings = {
      monitor = mkDefault [
        ",preferred,auto,1.0"
      ];
    };
  };
}
