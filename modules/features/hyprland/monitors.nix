{
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  wayland.windowManager.hyprland = {
    settings = {
      monitor = mkDefault [
        ",preferred,auto,1.0"
      ];
    };
  };
}
