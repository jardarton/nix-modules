{ localFlake, ... }:
{
  osConfig,
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.home.hypr;
in
{

  options.modules.home.hypr = {
    enable = mkOption {
      type = types.bool;
      default = osConfig != null && osConfig.programs ? hyprland && osConfig.programs.hyprland.enable;
      example = true;
      description = "enable hyprland home manager config";
    };
    package = mkOption {
      type = types.package;
      default = if osConfig != null && osConfig.programs ? hyprland
        then osConfig.programs.hyprland.package
        else pkgs.hyprland;
    };
    hypridle = mkOption {
      type = types.bool;
      default = cfg.enable;
      example = true;
      description = "enable hypridle";
    };
    hyprlock = mkOption {
      type = types.bool;
      default = cfg.enable;
      example = true;
      description = "enable hyprlock";
    };
    hyprsunset = mkOption {
      type = types.bool;
      default = cfg.enable;
      example = true;
      description = "enable hyprsunset";
    };
    hyprpaper = mkOption {
      type = types.bool;
      default = cfg.enable;
      example = true;
      description = "enable hyprpaper";
    };
    mainMod = mkOption {
      type = types.str;
      default = "SHIFT_CTRL_ALT";
      example = "SHIFT_CTRL_ALT";
      description = "main mod for hyprland";
    };
    cmdMod = mkOption {
      type = types.str;
      default = "SUPER";
      example = "SUPER";
      description = "command mod for hyprland";
    };
    launcher = mkOption {
      type = types.str;
      default = if cfg.enable then "fuzzel" else "";
      example = "rofi -show drun";
      description = "command of launcher to use";
    };
    lockpaper = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "/example/paper.png";
      description = "path to lockscreen wallpaper";
    };

  };

  imports = [
    ./binds.nix
    ./decorations.nix
    ./monitors.nix
    ./input.nix
    ./settings.nix
    ./hyprlock.nix
    ./hypridle.nix
    ./hyprsunset.nix
  ];

  config = mkIf cfg.enable {

    wayland.windowManager.hyprland = {
      enable = true;
      package = cfg.package;
      xwayland.enable = mkDefault true;
      systemd.enable = mkDefault (!osConfig.programs.hyprland.withUWSM); # to not intefere with withUwsm on programs.hyprland
      #https://wiki.hypr.land/Useful-Utilities/Systemd-start/
    };

    programs.wofi.enable = mkIf (strings.hasPrefix "wofi" cfg.launcher) true;
    programs.fuzzel.enable = mkIf (strings.hasPrefix "fuzzel" cfg.launcher) true;
    programs.rofi.enable = mkIf (strings.hasPrefix "rofi" cfg.launcher) true;
    services.hyprpaper.enable = cfg.hyprpaper;
  };
}
