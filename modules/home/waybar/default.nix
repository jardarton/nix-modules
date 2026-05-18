{ localFlake, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.home.waybar;
  color = config.lib.stylix.colors.withHashtag.base07;
  border-color = config.lib.stylix.colors.withHashtag.base04;
  background-color = config.lib.stylix.colors.withHashtag.base02;
in
{

  options.modules.home.waybar = {
    enable = mkOption {
      type = types.bool;
      default = true;
      example = true;
      description = "enable waybar";
    };
  };

  config = mkIf cfg.enable {

    stylix.targets.waybar.enable = true;
    stylix.targets.waybar.addCss = false;
    programs.waybar = {
      enable = true;
    };

    home.file.".config/waybar/config.jsonc".text = ''
      {
          "layer": "top",
          "position": "left",
          "exclusive": true,
          "passthrough": false,
          "gtk-layer-shell": true,
          "ipc": false,
          "reload_style_on_change": true,
          "modules-left": [
              "ext/workspaces",
              "dwl/window",
              "cava"
          ],
          "modules-right": [
              "tray",
              "clock",
              "battery",
              "network",
              "pulseaudio",
              "cpu",
              "temperature",
              "backlight",
              "custom/notification",
              "custom/power"
          ],
          "ext/workspaces": {
              "format": "{icon}",
              "ignore-hidden": true,
              // "active-only":true,
              "on-click": "activate",
              "on-click-right": "deactivate",
              "sort-by-id": true,
              "format-icons": {
                  "1": "",
                  "3": "",
                  "4": "",
                  "5": "",
                  "6": "",
                  "urgent": "",
                  "active": "",
                  "default": ""
              },
          },
          "dwl/window": {
              "format": "[{layout}]  {title}",
              "rotate": 90
          },
          "custom/notification": {
              "tooltip": false,
              "format": "{icon}",
              "format-icons": {
                  "notification": "<span foreground='red'><sup></sup></span>",
                  "none": "  ",
                  "dnd-notification": "<span foreground='red'><sup></sup></span>",
                  "dnd-none": "",
                  "inhibited-notification": "<span foreground='red'><sup></sup></span>",
                  "inhibited-none": "",
                  "dnd-inhibited-notification": "<span foreground='red'><sup></sup></span>",
                  "dnd-inhibited-none": ""
              },
              "return-type": "json",
              "exec-if": "which swaync-client",
              "exec": "swaync-client -swb",
              "on-click": "sleep 0.1s && swaync-client -t -sw",
              "on-click-right": "swaync-client -d -sw",
              "escape": true
          },
          "keyboard-state": {
              "numlock": false,
              "scrolllock": false,
              "capslock": true,
              "format": "{icon}",
              "format-icons": {
                  "locked": "Capslock",
                  "unlocked": ""
              }
          },
          "cpu": {
              "interval": 2,
              "format": " {load}%",
              "rotate": 90

          },
          "temperature": {
              "thermal-zone": 2,
              "hwmon-path": "/sys/class/hwmon/hwmon1/temp1_input",
              "critical-threshold": 10,
              "format-critical": " {temperatureC}°C",
              "format": "",
              "rotate": 90
          },
          "wlr/taskbar": {
              "format": "{icon}",
              "icon-size": 22,
              "all-outputs": false,
              "tooltip-format": "{title}",
              "markup": true,
              "on-click": "activate",
              "on-click-right": "close",
              "ignore-list": ["Rofi", "wofi"]
          },
          "backlight": {
              "interval": 2,
              "device": "amdgpu_bl0",
              "format": "{icon} {percent}%",
              "format-icons": ["󰖔", "󰖨"],
              "on-scroll-up": "brightnessctl set +1%",
              "on-scroll-down": "brightnessctl set 1%-",
              "smooth-scrolling-threshold": 1,
              "rotate": 90
          },
          "idle_inhibitor": {
              "tooltip": false,
              "format": "{icon}",
              "start-activated": false,
              "format-icons": {
                  "activated": " ",
                  "deactivated": " "
              }
          },
          "tray": {
              "interval": 1,
              "icon-size": 21,
              "spacing": 10
          },
          "network": {
              "interval": 2,
              "format-wifi": "\uf1eb {signalStrength}%",
              "format-ethernet": "󰈀",
              "format-linked": "\uf059 No IP ({ifname})",
              "format-disconnected": "\uf071 Disconnected",
              "tooltip-format": "{essid} {ifname} {ipaddr}/{cidr} via {gwaddr}",
              "format-alt": "↓{bandwidthDownBytes} ↑{bandwidthUpBytes}",
              "rotate": 90
          },
          "clock": {
              "format": " {:%H:%M}",
              "format-alt": " {:%A, %b %d}",
              "tooltip-format": "{:%Y}",
              "calendar": {
                  "mode": "year",
                  "mode-mon-col": 3,
                  "weeks-pos": "right",
                  "on-scroll": 1,
                  "format": {
                      "months": "<span color='#ffead3'><b>{}</b></span>",
                      "days": "<span color='#ecc6d9'><b>{}</b></span>",
                      "weeks": "<span color='#99ffdd'><b>W{}</b></span>",
                      "weekdays": "<span color='#ffcc66'><b>{}</b></span>",
                      "today": "<span color='#ff6699'><b><u>{}</u></b></span>"
                  }
              },
              "rotate": 90
          },
          "pulseaudio": {
              "format": "{icon} {volume}%",
              "tooltip": true,
              "format-muted": "  Muted",
              "on-click": "pamixer -t",
              "on-scroll-up": "pamixer -i 2",
              "on-scroll-down": "pamixer -d 2",
              "scroll-step": 5,
              "format-icons": {
                  "headphone": "",
                  "hands-free": "",
                  "headset": "",
                  "phone": "",
                  "portable": "",
                  "car": "",
                  "default": ["", "", ""]
              },
              "rotate": 90
          },
          "custom/power": {
              "format": "",
              "tooltip": false,
              "on-click": "wlogout -C ~/.config/mango/wlogout/style.css -l  ~/.config/mango/wlogout/layout  -b 6 --protocol layer-shell",
              "menu": "on-click-right",
              "menu-file": "~/.config/mango/waybar/battery_menu.xml",
              "menu-actions": {
                  "performance": "bash ~/.config/mango/scripts/power-profile  --performance",
                  "schedutil": "bash ~/.config/mango/scripts/power-profile --schedutil"
              }
          },
          "pulseaudio#microphone": {
              "format": "{format_source}",
              "format-source": " {volume}%",
              "tooltip": false,
              "format-source-muted": " Muted",
              "on-click": "pamixer --default-source -t",
              "on-scroll-up": "pamixer --default-source -i 2",
              "on-scroll-down": "pamixer --default-source -d 2",
              "scroll-step": 5
          },
          "custom/playerctl": {
              "format": "{2} <span>{0}</span>",
              "return-type": "json",
              "exec": "playerctl -p spotify metadata -f '{\"text\": \"{{markup_escape(title)}} - {{markup_escape(artist)}}  {{ duration(position) }}/{{ duration(mpris:length) }}\", \"tooltip\": \"{{markup_escape(title)}} - {{markup_escape(artist)}}  {{ duration(position) }}/{{ duration(mpris:length) }}\", \"alt\": \"{{status}}\", \"class\": \"{{status}}\"}' -F",
              "tooltip": false,
              "on-click-middle": "playerctl -p spotify previous",
              "on-click": "playerctl -p spotify play-pause",
              "on-click-right": "playerctl -p spotify next",
              "on-click-forward": "playerctl -p spotify position 10+",
              "on-click-backward": "playerctl -p spotify position 10-",
              "on-scroll-up": "playerctl -p spotify volume 0.02+",
              "on-scroll-down": "playerctl -p spotify volume 0.02-",
              "format-icons": {
                  "Paused": " ",
                  "Playing": " "
              }
          },
          "cava": {
              "framerate": 30,
              "autosens": 0,
              "sensitivity": 38,
              "bars": 8,
              "lower_cutoff_freq": 50,
              "higher_cutoff_freq": 12000,
              "method": "pulse",
              "hide_on_silence": false,
              "sleep_timer": 5,
              "source": "auto",
              "stereo": false,
              "reverse": false,
              "bar_delimiter": 0,
              "monstercat": false,
              "waves": false,
              "noise_reduction": 0.77,
              "input_delay": 0,
              "format-icons" : ["▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" ],
              "actions": {
                  "on-click-right": "mode"
              },
              "rotate": 90
          },
          "battery": {
              "bat": "BAT0",
              "interval": 1800,
              "states": {
                  "warning": 20,
                  "critical": 10
              },
              "format": "{icon} {capacity}%",
              "format-charging": " {capacity}%",
              "format-plugged": " {capacity}%",
              "format-alt": "{time} {icon}",
              "format-full": "󱈏 {capacity}%",
              "format-icons": ["󰂃", "󰁼", "󰁾", "󰂀", "󰁹"],
              "rotate": 90
          }
      }
    '';
    programs.waybar.style = ''
      * {
        border: none;
        font-weight: 900;
        font-size: 12px;
        min-height: 0;
      }

      window#waybar {
        background: none;
        margin: 0px;
        padding: 0px;
      }

      tooltip {
        background: rgba(40, 40, 40, 0.9);
        border-radius: 4px;
        border-width: 2px;
        border-style: solid;
        border-color: ${config.lib.stylix.colors.withHashtag.base06};
        color: ${config.lib.stylix.colors.withHashtag.base06};
      }

      #language,
      #custom-updates,
      #custom-weather,
      #window,
      #taskbar,
      #tags,
      #workspaces,
      #custom-playerctl,
      #clock,
      #battery,
      #pulseaudio,
      #cpu,
      #temperature,
      #backlight,
      #network,
      #workspaces,
      #tray,
      #cava,
      #keyboard-state,
      #custom-notification,
      #custom-power {
        padding: 10px 0px;
        margin: 8px 0px 8px 2px;
        border-radius: 4px;
        color: ${color};
        background-color: ${background-color};
        border-color: ${border-color};
      }

      #workspaces {
        border-radius: 4px;
        border-width: 2px;
        border-style: solid;
        border-color: ${config.lib.stylix.colors.withHashtag.base06};
        margin-left: 2px;
        background: rgba(40, 40, 40, 0.9);
      }

      #workspaces button {
        border: none;
        background: none;
        box-shadow: inherit;
        text-shadow: inherit;
        color: ${config.lib.stylix.colors.withHashtag.base05};
        padding: 1px;
        padding-left: 1px;
        padding-right: 1px;
      }

      #workspaces button.hidden {
        color: #9e906f;

        background-color: transparent;
      }

      #workspaces button.visible {
        color: #ddca9e;
      }

      #workspaces button:hover {
        color: #d79921;
      }

      #workspaces button.active {
        background-color: ${config.lib.stylix.colors.withHashtag.base0F};
        color: #282828;
        margin-top: 5px;
        margin-bottom: 5px;
        padding-top: 1px;
        padding-bottom: 0px;
        border-radius: 3px;
      }

      #workspaces button.urgent {
        background-color: ${config.lib.stylix.colors.withHashtag.base08};
        color: #282828;
        margin-top: 5px;
        margin-bottom: 5px;
        padding-top: 1px;
        padding-bottom: 0px;
        border-radius: 3px;
      }

      #tags {
        border-radius: 4px;
        border-width: 2px;
        border-style: solid;
        border-color: ${config.lib.stylix.colors.withHashtag.base06};
        margin-left: 2px;
        padding-left: 10px;
        padding-right: 6px;
        background: rgba(40, 40, 40, 0.9);
      }

      #tags button {
        border: none;
        background: none;
        box-shadow: inherit;
        text-shadow: inherit;
        color: #928374;
        padding: 1px;
        padding-left: 1px;
        padding-right: 1px;
        margin-right: 2px;
      }

      #tags button {
        color: #928374;
      }

      #tags button:not(.occupied):not(.focused):not(.overview):not(.urgent) {
        font-size: 0;
        min-width: 0;
        min-height: 0;
        margin: -17px;
        padding: 0;
        color: transparent;
        background-color: transparent;
      }

      #tags button.occupied {
        color: ${config.lib.stylix.colors.withHashtag.base0A};
      }

      #tags button.overview {
        color: #ddca9e;
      }

      #tags button:hover {
        color: #d79921;
      }

      #tags button.focused {
        background-color: #ddca9e;
        color: #282828;
        margin-top: 5px;
        margin-bottom: 5px;
        padding-top: 1px;
        padding-bottom: 0px;
        border-radius: 3px;
      }

      #tags button.urgent {
        background-color: #ef5e5e;
        color: #282828;
        margin-top: 5px;
        margin-bottom: 5px;
        padding-top: 1px;
        padding-bottom: 0px;
        border-radius: 3px;
      }

      #tray {
        background: rgba(40, 40, 40, 0.9);
        border-radius: 4px;
        border-width: 2px;
        border-style: solid;
        border-color: ${config.lib.stylix.colors.withHashtag.base06};
        margin-right: 2px;
        margin-left: 2px;
        padding-right: 8px;
        padding-left: 9px;
        padding-top: 2px;
        background-color: ${config.lib.stylix.colors.withHashtag.base0A};
      }

      #network {
        background: rgba(40, 40, 40, 0.9);
        border-radius: 4px;
        border-width: 2px;
        border-style: solid;
        border-color: ${config.lib.stylix.colors.withHashtag.base06};
        padding-top: 10px;
        color: ${config.lib.stylix.colors.withHashtag.base0D};
      }

      #workspaces {
        background: rgba(40, 40, 40, 0.9);
        border-radius: 4px;
        border-width: 2px;
        border-style: solid;
        border-color: ${config.lib.stylix.colors.withHashtag.base06};
      }

      #language {
        background: rgba(40, 40, 40, 0.9);
        background-color: ${config.lib.stylix.colors.withHashtag.base0C};
        border-width: 2px;
        border-style: solid;
        border-color: ${config.lib.stylix.colors.withHashtag.base06};
        border-right: 0px;
        border-radius: 4px 0px 0px 4px;
        min-width: 24px;
      }

      #keyboard-state {
        background: none;
        color: #ddca9e;
        border: none;
        padding-top: 1px;
      }

      #custom-updates {
        background: rgba(40, 40, 40, 0.9);
        color: #ddca9e;
        border-radius: 0px 4px 4px 0px;
        border-width: 2px;
        border-left: 0px;
        border-style: solid;
        border-color: ${config.lib.stylix.colors.withHashtag.base06};
      }

      #window {
        background: rgba(40, 40, 40, 0.9);
        border-width: 2px;
        border-style: solid;
        border-color: ${config.lib.stylix.colors.withHashtag.base06};
        border-radius: 4px;
        color: ${config.lib.stylix.colors.withHashtag.base05};
      }

      #taskbar {
        background: rgba(40, 40, 40, 0.9);
        border-width: 2px;
        border-style: solid;
        border-color: ${config.lib.stylix.colors.withHashtag.base06};
        border-radius: 4px;
        margin-left: 10px;
        margin-right: 10px;
        color: #ddca9e;
      }

      #taskbar.empty {
        margin-left: 0px;
        margin-right: 0px;
        padding-left: 10px;
        padding-right: 0px;
        border-radius: 0px;
        border-color: transparent;
        border: none;
        background-color: transparent;
      }

      #taskbar button {
        margin-right: 3px;
      }

      #taskbar button.minimized {
        background-color: #c4939d;
        color: #282828;
        margin-top: 5px;
        margin-bottom: 5px;
        padding-top: 0px;
        padding-bottom: 0px;
        padding-left: 3px;
        padding-right: 3px;
        border-radius: 3px;
      }

      #taskbar button.urgent {
        background-color: #ce3d0d;
        color: #282828;
        margin-top: 5px;
        margin-bottom: 5px;
        padding-top: 0px;
        padding-bottom: 0px;
        padding-left: 3px;
        padding-right: 3px;
        border-radius: 3px;
      }

      #taskbar button.active {
        background-color: #ddca9e;
        color: #282828;
        margin-top: 5px;
        margin-bottom: 5px;
        padding-top: 0px;
        padding-bottom: 0px;
        padding-left: 3px;
        padding-right: 3px;
        border-radius: 3px;
      }

      #custom-playerctl {
        background: rgba(40, 40, 40, 0.9);
        border-width: 2px;
        border-style: solid;
        border-color: ${config.lib.stylix.colors.withHashtag.base06};
        border-right: 0px;
        border-left: 0px;
        color: #ddca9e;
      }

      #cava {
        background: rgba(40, 40, 40, 0.9);
        border-radius: 4px;
        border-width: 2px;
        border-style: solid;
        margin-left: 4px;
        color: ${config.lib.stylix.colors.withHashtag.base0D};
      }

      #clock {
        color: ${config.lib.stylix.colors.withHashtag.base0A};
        background: rgba(40, 40, 40, 0.9);
        border-width: 2px;
        border-style: solid;
      }

      #pulseaudio {
        background: rgba(40, 40, 40, 0.9);
        border-width: 2px;
        border-style: solid;
      }

      #cpu {
        background: rgba(40, 40, 40, 0.9);
        color: ${config.lib.stylix.colors.withHashtag.base0C};
        border-width: 2px;
        border-style: solid;
      }

      #temperature {
        background: rgba(40, 40, 40, 0.9);
        border-width: 2px;
        border-style: solid;
      }

      #backlight {
        background: rgba(40, 40, 40, 0.9);
        border-width: 2px;
        border-style: solid;
        border-color: ${config.lib.stylix.colors.withHashtag.base06};
      }

      #battery {
        background: rgba(40, 40, 40, 0.9);
        color: ${config.lib.stylix.colors.withHashtag.base0B};
        border-width: 2px;
        border-style: solid;
        border-color: ${config.lib.stylix.colors.withHashtag.base06};
      }

      #custom-weather {
        background: rgba(40, 40, 40, 0.9);
        border-radius: 4px 0px 0px 4px;
        border-width: 2px;
        border-style: solid;
        border-color: ${config.lib.stylix.colors.withHashtag.base06};
        border-right: 0px;
        padding-top: 1px;
      }

      #custom-notification {
        background: rgba(40, 40, 40, 0.9);
        border-width: 2px;
        border-style: solid;
        border-color: ${config.lib.stylix.colors.withHashtag.base06};
      }

      #custom-power {
        background: rgba(40, 40, 40, 0.9);
        border-width: 2px;
        border-style: solid;
        border-color: ${config.lib.stylix.colors.withHashtag.base06};
        border-radius: 4px;
      }

      menu {
        border-width: 2px;
        border-style: solid;
        border-color: ${config.lib.stylix.colors.withHashtag.base06};
        background: rgba(40, 40, 40, 0.9);
        border-radius: 10px;
      }

      menuitem:focus label,
      menuitem:hover label {
        color: #010101;
        background: #c9b890;
      }

      menuitem:focus,
      menuitem:hover {
        background: #c9b890;
      }
    '';
  };
}
