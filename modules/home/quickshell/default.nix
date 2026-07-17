{ localFlake, ... }:
{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.home.quickshell;
in
{
  imports = [
  ];

  options.modules.home.quickshell = {
    enable = mkEnableOption "caelestia with quickshell";
  };

  config = mkIf cfg.enable {
    # Main packages
    home.packages = with pkgs; [
      quickshell
      pkg-caelestia-cli
      ddcutil
      brightnessctl
      cava
      networkmanager
      bluez
      bluez-tools
      lm_sensors
      fish
      curl
      power-profiles-daemon
      cliphist
      jq
      socat
      imagemagick
      papirus-icon-theme
      wl-clipboard
      playerctl
      trash-cli
      xdg-desktop-portal-gtk
      fastfetch
      wireplumber
      qt6.qt5compat
      qt6.qtdeclarative

      # Runtime dependencies
      hyprpaper
      imagemagick
      wl-clipboard
      fuzzel
      socat
      grim
      wayfreeze
      wl-screenrec

      #fonts
      nerd-fonts.jetbrains-mono
      ibm-plex
      departure-mono
      material-symbols
    ];

    # Wrapper for caelestia to work with quickshell
    #   (writeScriptBin "caelestia-quickshell" ''
    #     #!${pkgs.fish}/bin/fish
    #
    #     # Override for caelestia shell commands to work with quickshell
    #     set -l original_caelestia ${pkgs.pkg-caelestia-cli}/bin/caelestia
    #
    #     if test "$argv[1]" = "shell" -a -n "$argv[2]"
    #         set -l cmd $argv[2]
    #         set -l args $argv[3..]
    #
    #         switch $cmd
    #             case "show" "toggle"
    #                 if test -n "$args[1]"
    #                     exec ${config.programs.quickshell.finalPackage}/bin/qs -c caelestia ipc call drawers $cmd $args[1]
    #                 else
    #                     echo "Usage: caelestia shell $cmd <drawer>"
    #                     exit 1
    #                 end
    #             case "media"
    #                 if test -n "$args[1]"
    #                     set -l action $args[1]
    #                     switch $action
    #                         case "play-pause"
    #                             exec ${config.programs.quickshell.finalPackage}/bin/qs -c caelestia ipc call mpris playPause
    #                         case '*'
    #                             exec ${config.programs.quickshell.finalPackage}/bin/qs -c caelestia ipc call mpris $action
    #                     end
    #                 else
    #                     echo "Usage: caelestia shell media <action>"
    #                     exit 1
    #                 end
    #             case '*'
    #                 # For other shell commands, try the original
    #                 exec $original_caelestia $argv
    #         end
    #     else
    #         # For non-shell commands, use the original
    #         exec $original_caelestia $argv
    #     end
    #   '')
    # ];
    #
    # # Systemd service
    # systemd.user.services.caelestia-shell = {
    #   Unit = {
    #     Description = "Caelestia desktop shell";
    #     After = [ "graphical-session.target" ];
    #   };
    #   Service = {
    #     Type = "exec";
    #     ExecStart = "${config.programs.quickshell.finalPackage}/bin/qs -c caelestia";
    #     Restart = "on-failure";
    #     Slice = "app-graphical.slice";
    #   };
    #   Install = {
    #     WantedBy = [ "graphical-session.target" ];
    #   };
    # };
    #
    # # Shell aliases
    # home.shellAliases = {
    #   caelestia-shell = "qs -c caelestia";
    #   caelestia-edit = "cd ${config.xdg.configHome}/quickshell/caelestia && $EDITOR";
    #   caelestia = "caelestia-quickshell";
    # };
  };
}
