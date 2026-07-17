{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.modules.home.hypr;
in
with lib;
{

  home.file.".local/scripts/run_or_raise" = {
    executable = true;
    text = ''
      # command classname pidname
      windowClassname=''${2:-$1}
      pidName=''${3:-$1}
      pidof $pidName && hyprctl dispatch focuswindow class:".*$windowClassname" || uwsm app -- $1&
    '';
  };

  wayland.windowManager.hyprland = {
    settings = {
      "$command" = cfg.cmdMod;
      # Sets "meh" key as main modifier
      "$mainMod" = cfg.mainMod;

      ## See more in modules/applications/* and modules/desktop/utils/*
      bind = lib.mkDefault [
        #Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more

        # "$command, X, exec, wtype -P XF86Cut"
        # "$command, C, exec, wtype -M ctrl c -m ctrl" # XF86Copy"
        # "$command, V, exec, wtype -M ctrl -M shift v -m shift -m ctrl" # -P XF86Paste"
        "$mainMod, RETURN, fullscreenstate, 1, 1"
        "$command, RETURN, fullscreen"

        "$mainMod, SPACE, exec, run_or_raise $terminal"
        "$mainMod, E, exec, run_or_raise firefox"
        "$command, Q, killactive,"
        "$mainMod, ESCAPE, exit,"
        "$mainMod, F, exec, $fileManager"
        "$mainMod, V, togglefloating,"
        "$command, SPACE, exec, $menu"
        "$command, U, exec, bemenu-run"
        "$mainMod, P, pseudo, # dwindle"
        "$mainMod, c, togglesplit, # dwindle"

        "$mainMod, A, focuscurrentorlast"

        #focus with mainMod + arrow keys
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"

        #Switch workspaces with mainMod + [0-9]
        "$mainMod, 0, workspace, 0"
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"

        #Move active window to a workspace with mainMod + SHIFT + [0-9]
        "$mainMod $command, 0, movetoworkspace, 0"
        "$mainMod $command, 1, movetoworkspace, 1"
        "$mainMod $command, 2, movetoworkspace, 2"
        "$mainMod $command, 3, movetoworkspace, 3"
        "$mainMod $command, 4, movetoworkspace, 4"
        "$mainMod $command, 5, movetoworkspace, 5"
        "$mainMod $command, 6, movetoworkspace, 6"
        "$mainMod $command, 7, movetoworkspace, 7"
        "$mainMod $command, 8, movetoworkspace, 8"
        "$mainMod $command, 9, movetoworkspace, 9"

        # Example special workspace (scratchpad)
        # bind = $mainMod, S, togglespecialworkspace, magic
        # bind = $mainMod SHIFT, S, movetoworkspace, special:magic

        # Scroll through existing workspaces with mainMod + scroll
        "$mainMod, mouse_down, workspace, e+1"
        "bind = $mainMod, mouse_up, workspace, e-1"

      ];

      # Move/resize windows with mainMod + LMB/RMB and dragging
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      # Laptop multimedia keys for volume and LCD brightness
      bindl = [
        " ,XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        " ,XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        " ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        " ,XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        " ,XF86MonBrightnessUp, exec, brightnessctl s 10%+"
        " ,XF86MonBrightnessDown, exec, brightnessctl s 10%-"
        #requrires playerctl
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioPlay, exec, playerctl play-pause"
        " , XF86AudioPrev, exec, playerctl previous"

      ];
      #   "SUPER, F, fullscreenstate, 1, 1"
      #   "SUPER_SHIFT, F, fullscreen"
      #   "SUPER, P, pin" # Pin dispatcher, make window appear above everything else on all windows
      #   # See Terminal for the bind for SUPER, RETURN
      #   "SUPER, V, togglefloating,"
      #   "SUPER, mouse:274, killactive" # Middle Mouse
      #   "SUPER, space, pseudo,"
      #
      #   "SUPER_SHIFT, Q, killactive"
      #   "ALT, Tab, bringactivetotop,"
      #   "ALT, Tab, cyclenext,"
      #   #"ALT,TAB,workspace,previous"
      #
      #   # Move focus with mainMod + arrow keys
      #   "SUPER, left, movefocus, l"
      #   "SUPER, right, movefocus, r"
      #   "SUPER, up, movefocus, u"
      #   "SUPER, down, movefocus, d"
    };
  };
}
