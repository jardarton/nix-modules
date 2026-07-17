{ localFlake, ... }:
{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.home.mango;
in
{
  imports = [
    localFlake.inputs.mango.hmModules.mango
  ];

  options.modules.home.mango = {
    enable = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = "enable mango config";
    };
    mainmod = mkOption {
      type = types.str;
      default = "Ctrl+Shift+Alt";
      example = "Ctrl+Shift+Alt";
    };
    blur = mkEnableOption "blur effect";
    extraSettings = mkOption {
      type = types.str;
      default = "";
    };
    terminal = mkOption {
      type = types.str;
      default = "foot";
      example = "foot";
    };
    cProgram = mkOption {
      type = types.str;
      default = "google-chrome-stable";
      example = "chromium";
    };
  };

  config = mkIf cfg.enable {

    programs.swaylock.enable = true;
    programs.foot.enable = true;
    services.hyprpaper.enable = true;

    home = {
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "wayland";
        BEMOJI_PICKER_CMD = "dmenu";
      };
      packages = [
        pkgs.swaynotificationcenter
        pkgs.swaybg
        pkgs.wl-clipboard
        pkgs.swaylock-fancy
        pkgs.bemoji
      ];
    };

    wayland.windowManager.mango = {
      enable = true;
      # Window effect
      settings = ''
        blur=${if cfg.blur then "1" else "0"}
        blur_layer=0
        blur_optimized=1
        blur_params_num_passes = 2
        blur_params_radius = 5
        blur_params_noise = 0.02
        blur_params_brightness = 0.9
        blur_params_contrast = 0.9
        blur_params_saturation = 1.2

        shadows = 1
        layer_shadows = 1
        shadow_only_floating=1
        shadows_size = 12
        shadows_blur = 15
        shadows_position_x = 0
        shadows_position_y = 0
        shadowscolor= 0x000000ff

        border_radius=6
        no_radius_when_single=0
        focused_opacity=${if cfg.blur then "0.8" else "0.90"}
        unfocused_opacity=${if cfg.blur then "0.7" else "0.80"}

        animations=1
        layer_animations=1
        animation_type_open=zoom
        animation_type_close=slide
        animation_fade_in=1
        animation_fade_out=1
        tag_animation_direction=0
        zoom_initial_ratio=0.3
        zoom_end_ratio=0.8
        fadein_begin_opacity=0.5
        fadeout_begin_opacity=0.8
        animation_duration_move=150
        animation_duration_open=400
        animation_duration_tag=250
        animation_duration_close=700
        animation_curve_open=0.46,1.0,0.29,1
        animation_curve_move=0.46,1.0,0.29,1
        animation_curve_tag=0.46,1.0,0.29,1
        animation_curve_close=0.08,0.92,0,1

        scroller_structs=20
        scroller_default_proportion=0.8
        scroller_focus_center=0
        scroller_prefer_center=0
        edge_scroller_pointer_focus=1
        scroller_default_proportion_single=1.0
        scroller_proportion_preset=0.5,0.8,1.0

        new_is_master=0
        default_mfact=0.55
        default_nmaster=1
        smartgaps=0

        hotarea_size=10
        enable_hotarea=1
        ov_tab_mode=0
        overviewgappi=5
        overviewgappo=30

        no_border_when_single=0
        axis_bind_apply_timeout=100
        focus_on_activate=1
        sloppyfocus=1
        warpcursor=1
        focus_cross_monitor=0
        focus_cross_tag=0
        enable_floating_snap=0
        snap_distance=30
        cursor_size=24
        drag_tile_to_tile=1

        repeat_rate=25
        repeat_delay=600
        numlockon=1
        xkb_rules_layout=us,no
        bind=ALT,code:36,switch_keyboard_layout

        disable_trackpad=0
        tap_to_click=0
        tap_and_drag=1
        drag_lock=1
        trackpad_natural_scrolling=1
        disable_while_typing=1
        left_handed=0
        middle_button_emulation=0
        swipe_min_threshold=1

        mouse_natural_scrolling=1

        gappih=5
        gappiv=5
        gappoh=10
        gappov=10
        scratchpad_width_ratio=0.8
        scratchpad_height_ratio=0.9
        borderpx=4
        rootcolor=0x201b14ff
        bordercolor=0x444444ff
        focuscolor=0xc9b890ff
        maximizescreencolor=0x89aa61ff
        urgentcolor=0xad401fff
        scratchpadcolor=0x516c93ff
        globalcolor=0xb153a7ff
        overlaycolor=0x14a57cff

        tagrule=id:1,layout_name:scroller
        tagrule=id:2,layout_name:scroller
        tagrule=id:3,layout_name:scroller
        tagrule=id:4,layout_name:scroller
        tagrule=id:5,layout_name:scroller
        tagrule=id:6,layout_name:scroller
        tagrule=id:7,layout_name:scroller
        tagrule=id:8,layout_name:scroller
        tagrule=id:9,layout_name:scroller

        bind=${cfg.mainmod},r,reload_config

        bind=SUPER,space,spawn,foot --title launcher -e fsel -d
        bind=SUPER,y,spawn,foot --title launcher fsel --cclip -r

        bind=${cfg.mainmod},space,spawn_on_empty, ${cfg.terminal},4
        bind=${cfg.mainmod},e,spawn_on_empty,firefox,5
        bind=${cfg.mainmod},c,spawn_on_empty,${cfg.cProgram},6
        bind=${cfg.mainmod},m,spawn_on_empty,spotify,1
        bind=${cfg.mainmod},s,spawn_on_empty,slack,2
        bind=Super+Shift,w,quit
        bind=SUPER,q,killclient,

        bind=Ctrl+Shift,code:23,focusstack,next
        bind=${cfg.mainmod},l,focusdir,right
        bind=${cfg.mainmod},h,focusdir,left
        bind=${cfg.mainmod},k,focusdir,up
        bind=${cfg.mainmod},j,focusdir,down

        bind=SUPER+SHIFT,Up,exchange_client,up
        bind=SUPER+SHIFT,Down,exchange_client,down
        bind=SUPER+SHIFT,Left,exchange_client,left
        bind=SUPER+SHIFT,Right,exchange_client,right

        bind=SUPER,g,toggleglobal,
        bind=Super,Tab,toggleoverview,
        bind=Super,code:9,togglefloating,
        bind=Super,m,togglemaximizescreen,
        bind=${cfg.mainmod},code:36,togglefullscreen,
        bind=ALT+SHIFT,f,togglefakefullscreen,
        bind=SUPER,o,toggleoverlay,
        bind=ALT,z,toggle_scratchpad

        bind=ALT,e,set_proportion,1.0
        bind=ALT,x,switch_proportion_preset,

        bind=SUPER,l,switch_layout

        bind=SUPER,Up,viewtoleft,0
        bind=CTRL,Up,viewtoleft_have_client,0
        bind=SUPER,Down,viewtoright,0
        bind=CTRL,Down,viewtoright_have_client,0
        bind=CTRL+SUPER,Left,tagtoleft,0
        bind=CTRL+SUPER,Right,tagtoright,0

        bind=${cfg.mainmod},a,focuslast

        bind=${cfg.mainmod},1,view,1,0
        bind=${cfg.mainmod},2,view,2,0
        bind=${cfg.mainmod},3,view,3,0
        bind=${cfg.mainmod},4,view,4,0
        bind=${cfg.mainmod},5,view,5,0
        bind=${cfg.mainmod},6,view,6,0
        bind=${cfg.mainmod},7,view,7,0
        bind=${cfg.mainmod},8,view,8,0
        bind=${cfg.mainmod},9,view,9,0

        bind=CTRL+SHIFT+SUPER+ALT,1,tag,1,0
        bind=CTRL+SHIFT+SUPER+ALT,2,tag,2,0
        bind=CTRL+SHIFT+SUPER+ALT,3,tag,3,0
        bind=CTRL+SHIFT+SUPER+ALT,4,tag,4,0
        bind=CTRL+SHIFT+SUPER+ALT,5,tag,5,0
        bind=CTRL+SHIFT+SUPER+ALT,6,tag,6,0
        bind=CTRL+SHIFT+SUPER+ALT,7,tag,7,0
        bind=CTRL+SHIFT+SUPER+ALT,8,tag,8,0
        bind=CTRL+SHIFT+SUPER+ALT,9,tag,9,0

        bind=${cfg.mainmod},code:23,focusmon,left
        bind=alt+shift,Right,focusmon,right
        bind=${cfg.mainmod}+Super,code:23,tagmon,left
        bind=SUPER+Alt,Right,tagmon,right

        bind=ALT+SHIFT,X,incgaps,2
        bind=ALT+SHIFT,Z,incgaps,-1
        bind=ALT+SHIFT,R,togglegaps

        bind=CTRL+SHIFT,Up,movewin,+0,-50
        bind=CTRL+SHIFT,Down,movewin,+0,+50
        bind=CTRL+SHIFT,Left,movewin,-50,+0
        bind=CTRL+SHIFT,Right,movewin,+50,+0

        bind=CTRL+ALT,Up,resizewin,+0,-50
        bind=CTRL+ALT,Down,resizewin,+0,+50
        bind=CTRL+ALT,Left,resizewin,-50,+0
        bind=CTRL+ALT,Right,resizewin,+50,+0

        mousebind=SUPER,btn_left,moveresize,curmove
        mousebind=SUPER,btn_right,moveresize,curresize

        axisbind=SUPER,UP,viewtoleft_have_client
        axisbind=SUPER,DOWN,viewtoright_have_client

        bind=${cfg.mainmod},x,spawn,swaylock-fancy -d -p
        bind=${cfg.mainmod}+Super,p,spawn,foot --title launcher -e bash rbw-copy
        bind=${cfg.mainmod}+Super,s,spawn_shell,screenshot-area-clipboard
        bind=${cfg.mainmod}+Super,f,spawn_shell,screenshot-area-file
        bind=${cfg.mainmod},y,spawn,foot -e bash -c yazi
        bind=${cfg.mainmod},b,spawn,${cfg.terminal}
        bind=SUPER,s,spawn,foot --title launcher -e bash bemoji

        layerrule=animation_type_open:zoom,layer_name:rofi
        layerrule=animation_type_close:zoom,layer_name:rofi

        windowrule=width:600,height:800,isfloating:1,focused_opacity:1.0,title:launcher

        bind=NONE,XF86MonBrightnessDown,spawn,brightnessctl set 5%-
        bind=NONE,XF86MonBrightnessUp,spawn,brightnessctl set +5%
        bind=NONE,XF86AudioRaiseVolume,spawn,pamixer -i 5
        bind=NONE,XF86AudioLowerVolume,spawn,pamixer -d 5
        bind=NONE,XF86AudioMute,spawn,pamixer -t

        gesturebind=none,up,3,viewtoleft_have_client
        gesturebind=none,down,3,viewtoleft_have_client

        exec-once=waybar
      ''
      + cfg.extraSettings;
      autostart_sh = ''
        set +e

        wlr-randr --output DP-2 --left-of eDP-1 &
        wlr-randr --output DP-3 --left-of eDP-1 &

        # obs
        dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=wlroots
        /usr/lib/xdg-desktop-portal-wlr &

        # notify
        swaync &

        # xwayland dpi scale
        echo "Xft.dpi: 140" | xrdb -merge &
        gsettings set org.gnome.desktop.interface text-scaling-factor 1.4 &

        # Permission authentication
        /usr/lib/xfce-polkit/xfce-polkit &

        cclipd -s 2 -t "image/png" -t "image/*" -t "text/plain;charset=utf-8" -t "text/*" -t "*" &
      '';
    };
  };
}
