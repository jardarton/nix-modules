{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    optional
    optionalString
    types
    ;

  cfg = config.modules.home.mango;

  defaultSettings = {
    # Window effects
    blur = if cfg.blur then 1 else 0;
    blur_layer = 0;
    blur_optimized = 1;
    blur_params_num_passes = 2;
    blur_params_radius = 5;
    blur_params_noise = 0.02;
    blur_params_brightness = 0.9;
    blur_params_contrast = 0.9;
    blur_params_saturation = 1.2;

    shadows = 1;
    layer_shadows = 1;
    shadow_only_floating = 1;
    shadows_size = 12;
    shadows_blur = 15;
    shadows_position_x = 0;
    shadows_position_y = 0;
    shadows_color = "0x000000ff";

    border_radius = 6;
    no_radius_when_single = 0;
    focused_opacity = if cfg.blur then 0.8 else 0.9;
    unfocused_opacity = if cfg.blur then 0.7 else 0.8;

    # Animations
    animations = 1;
    layer_animations = 1;
    animation_type_open = "zoom";
    animation_type_close = "slide";
    animation_fade_in = 1;
    animation_fade_out = 1;
    tag_animation_direction = 0;
    zoom_initial_ratio = 0.3;
    zoom_end_ratio = 0.8;
    fade_in_begin_opacity = 0.5;
    fade_out_begin_opacity = 0.8;
    animation_duration_move = 150;
    animation_duration_open = 400;
    animation_duration_tag = 250;
    animation_duration_close = 700;
    animation_curve_open = "0.46,1.0,0.29,1";
    animation_curve_move = "0.46,1.0,0.29,1";
    animation_curve_tag = "0.46,1.0,0.29,1";
    animation_curve_close = "0.08,0.92,0,1";

    # Layout defaults
    scroller_structs = 20;
    scroller_default_proportion = 0.8;
    scroller_focus_center = 0;
    scroller_prefer_center = 0;
    edge_scroller_pointer_focus = 1;
    scroller_default_proportion_single = 1.0;
    scroller_proportion_preset = "0.5,0.8,1.0";
    new_is_master = 0;
    default_master_factor = 0.55;
    default_master_count = 1;
    smart_gaps = 0;

    # Overview and focus behavior
    hotarea_size = 10;
    enable_hotarea = 1;
    overview_gap_inner = 5;
    overview_gap_outer = 30;
    no_border_when_single = 0;
    axis_bind_apply_timeout = 100;
    focus_on_activate = 1;
    sloppy_focus = 1;
    warp_cursor = 1;
    focus_cross_monitor = 0;
    focus_cross_tag = 0;
    enable_floating_snap = 0;
    snap_distance = 30;
    cursor_size = 24;
    drag_tile_to_tile = 1;

    # Generic keyboard and pointer defaults. Consumers should set their own
    # layout and any device-specific policy.
    repeat_rate = 25;
    repeat_delay = 600;
    numlock_on = 1;
    disable_trackpad = 0;
    tap_to_click = 0;
    tap_and_drag = 1;
    drag_lock = 1;
    trackpad_natural_scrolling = 1;
    trackpad_disable_while_typing = 1;
    trackpad_left_handed = 0;
    trackpad_middle_button_emulation = 0;
    swipe_min_threshold = 1;
    mouse_natural_scrolling = 1;

    # Appearance
    gap_inner_horizontal = 5;
    gap_inner_vertical = 5;
    gap_outer_horizontal = 10;
    gap_outer_vertical = 10;
    scratchpad_width_ratio = 0.8;
    scratchpad_height_ratio = 0.9;
    border_px = 4;
    root_color = "0x201b14ff";
    border_color = "0x444444ff";
    focus_color = "0xc9b890ff";
    maximized_screen_color = "0x89aa61ff";
    urgent_color = "0xad401fff";
    scratchpad_color = "0x516c93ff";
    global_color = "0xb153a7ff";
    overlay_color = "0x14a57cff";

    tag_rule = map (tag: "id:${toString tag},layout_name:scroller") (lib.range 1 9);

    # These are compositor-management bindings only. Application, media,
    # lock-screen, and desktop-component bindings belong to consumers.
    bind = [
      "${cfg.mainmod},r,reload_config"
      "Super+Shift,w,quit"
      "SUPER,q,killclient,"
      "Ctrl+Shift,code:23,focusstack,next"
      "${cfg.mainmod},l,focusdir,right"
      "${cfg.mainmod},h,focusdir,left"
      "${cfg.mainmod},k,focusdir,up"
      "${cfg.mainmod},j,focusdir,down"
      "SUPER+SHIFT,Up,exchange_client,up"
      "SUPER+SHIFT,Down,exchange_client,down"
      "SUPER+SHIFT,Left,exchange_client,left"
      "SUPER+SHIFT,Right,exchange_client,right"
      "SUPER,g,toggleglobal,"
      "Super,Tab,toggleoverview,"
      "Super,code:9,togglefloating,"
      "Super,m,togglemaximizescreen,"
      "${cfg.mainmod},code:36,togglefullscreen,"
      "ALT+SHIFT,f,togglefakefullscreen,"
      "SUPER,o,toggleoverlay,"
      "ALT,z,toggle_scratchpad,"
      "ALT,e,set_proportion,1.0"
      "ALT,x,switch_proportion_preset,"
      "SUPER,l,switch_layout,"
      "SUPER,Up,viewtoleft,0"
      "CTRL,Up,viewtoleft_have_client,0"
      "SUPER,Down,viewtoright,0"
      "CTRL,Down,viewtoright_have_client,0"
      "CTRL+SUPER,Left,tagtoleft,0"
      "CTRL+SUPER,Right,tagtoright,0"
      "${cfg.mainmod},a,focuslast,"
    ]
    ++ map (tag: "${cfg.mainmod},${toString tag},view,${toString tag},0") (lib.range 1 9)
    ++ map (tag: "CTRL+SHIFT+SUPER+ALT,${toString tag},tag,${toString tag},0") (lib.range 1 9)
    ++ [
      "${cfg.mainmod},code:23,focusmon,left"
      "alt+shift,Right,focusmon,right"
      "${cfg.mainmod}+Super,code:23,tagmon,left"
      "SUPER+Alt,Right,tagmon,right"
      "ALT+SHIFT,X,incgaps,2"
      "ALT+SHIFT,Z,incgaps,-1"
      "ALT+SHIFT,R,togglegaps,"
      "CTRL+SHIFT,Up,movewin,+0,-50"
      "CTRL+SHIFT,Down,movewin,+0,+50"
      "CTRL+SHIFT,Left,movewin,-50,+0"
      "CTRL+SHIFT,Right,movewin,+50,+0"
      "CTRL+ALT,Up,resizewin,+0,-50"
      "CTRL+ALT,Down,resizewin,+0,+50"
      "CTRL+ALT,Left,resizewin,-50,+0"
      "CTRL+ALT,Right,resizewin,+50,+0"
    ];

    mousebind = [
      "SUPER,btn_left,moveresize,curmove"
      "SUPER,btn_right,moveresize,curresize"
    ];
    axisbind = [
      "SUPER,UP,viewtoleft_have_client"
      "SUPER,DOWN,viewtoright_have_client"
    ];
    gesturebind = [
      "none,up,3,viewtoleft_have_client"
      "none,down,3,viewtoleft_have_client"
    ];

    exec_once =
      optional (cfg.wallpaper != null) "swaybg -i ${cfg.wallpaper} -m fill" ++ cfg.extraAutostartCommands;
  };
in
{
  options.modules.home.mango = {
    enable = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = "Whether to enable the reusable Mango compositor configuration.";
    };

    package = mkOption {
      type = types.package;
      description = "The Mango package used by the session and Home Manager configuration.";
    };

    mainmod = mkOption {
      type = types.str;
      default = "Ctrl+Shift+Alt";
      example = "ALT";
      description = ''
        Modifier used by the default compositor-management bindings. Override
        `wayland.windowManager.mango.settings.bind` to replace those bindings entirely.
      '';
    };

    blur = mkEnableOption "the reusable Mango blur defaults";

    extraSettings = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Extra raw Mango configuration appended after the structured settings.
        Prefer `wayland.windowManager.mango.settings` for new configuration.
      '';
    };

    wallpaper = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        Optional wallpaper displayed by swaybg. When null, this module neither
        installs nor starts a wallpaper provider.
      '';
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      example = lib.literalExpression "with pkgs; [ jq ]";
      description = ''
        Additional packages for a consumer's Mango session. No bar,
        notification daemon, terminal, clipboard daemon, or idle daemon is
        installed by default.
      '';
    };

    extraAutostartCommands = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "my-session-service" ];
      description = ''
        Additional commands emitted as Mango `exec_once` entries. Use native
        Home Manager service options when one exists for the program.
      '';
    };
  };

  config = mkIf cfg.enable {
    home = {
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      };
      packages = cfg.extraPackages ++ optional (cfg.wallpaper != null) pkgs.swaybg;
    };

    wayland.windowManager.mango = {
      enable = true;
      inherit (cfg) package;

      # Keep each setting independently overrideable. In particular, a
      # consumer definition of a list such as `bind` replaces this default
      # instead of being concatenated with it.
      settings = lib.mapAttrs (_: mkDefault) defaultSettings;

      extraConfig = optionalString (cfg.extraSettings != "") cfg.extraSettings;

      # The upstream module only emits its systemd environment import and
      # starts mango-session.target when autostart_sh is non-empty. Keep the
      # script present even when this module has no desktop adjuncts to start.
      autostart_sh = ":";

      # Mango sets this after creating its IPC socket. Importing it here makes
      # mmsg available to services started by mango-session.target.
      systemd.variables = mkDefault [
        "DISPLAY"
        "WAYLAND_DISPLAY"
        "XDG_CURRENT_DESKTOP"
        "XDG_SESSION_TYPE"
        "NIXOS_OZONE_WL"
        "XCURSOR_THEME"
        "XCURSOR_SIZE"
        "MANGO_INSTANCE_SIGNATURE"
      ];
    };
  };
}
