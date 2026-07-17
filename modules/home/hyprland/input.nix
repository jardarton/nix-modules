{
  lib,
  ...
}:
with lib;
{
  wayland.windowManager.hyprland = {
    settings = {
      input = {
        kb_options = "ctrl:nocaps";
        follow_mouse = 1;
        kb_layout = "us,no";
        kb_model = "";
        kb_rules = "";
        kb_variant = "";
        numlock_by_default = true;
        repeat_delay = 200;
        repeat_rate = 40;
        sensitivity = 0;
        touchpad = {
          natural_scroll = true;
        };
      };
      gesture = [
        "3, vertical, workspace"
        "3, left, dispatcher, movefocus, r"
        "3, right, dispatcher, movefocus, l"
      ];
    };
  };
}
