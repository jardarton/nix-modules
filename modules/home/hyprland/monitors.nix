{
  lib,
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
