_:
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.nixos.home-assistant;
  mosquittoConfig = pkgs.writeText "mosquitto-home-assistant.conf" ''
    listener ${toString cfg.mosquitto.port} ${cfg.mosquitto.bindAddress}
    allow_anonymous ${if cfg.mosquitto.allowAnonymous then "true" else "false"}

    persistence true
    persistence_location /mosquitto/data/
    autosave_interval 60

    connection_messages false
    log_dest stdout
  '';
in
{
  options.modules.nixos.home-assistant = with lib; {
    enable = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = "enable hass stack";
    };
    confDir = mkOption {
      type = types.str;
      default = "/var/lib/hass";
      description = "Location to store config";
    };
    image = mkOption {
      type = types.str;
      default = "ghcr.io/home-assistant/home-assistant@sha256:f73512ba4fe06bb4d57636fe3578d0820cdec46f81e8f837ab59e451662ff3cb";
      description = "Home Assistant container image, preferably pinned by digest.";
    };
    zigbee2mqtt = {
      enable = mkOption {
        type = types.bool;
        default = true;
        example = false;
        description = "Run Zigbee2MQTT alongside the Home Assistant podman container.";
      };
      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/zigbee2mqtt";
        description = "Location to store Zigbee2MQTT data and configuration.";
      };
      image = mkOption {
        type = types.str;
        default = "ghcr.io/koenkk/zigbee2mqtt@sha256:80f7f04f72a99e4c4ef51ef7e98ee736edba6db0ecbb7abc626d0c4b0f1871f1";
        description = "Zigbee2MQTT container image, preferably pinned by digest.";
      };
      adapter = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "/dev/serial/by-id/usb-Texas_Instruments_TI_CC2531_USB_CDC___0X00124B0018ED3DDF-if00";
        description = "Host path for the Zigbee adapter. Prefer /dev/serial/by-id/* paths.";
      };
    };
    mosquitto = {
      enable = mkOption {
        type = types.bool;
        default = true;
        example = false;
        description = "Run Eclipse Mosquitto as the MQTT broker for the Home Assistant stack.";
      };
      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/mosquitto";
        description = "Location to store Mosquitto persistent data.";
      };
      image = mkOption {
        type = types.str;
        default = "docker.io/library/eclipse-mosquitto@sha256:6f8d8a947c506f8a2290ec65cd4bd2bc7cb4d43fb5f6271f861cb013e2ef9797";
        description = "Mosquitto container image, preferably pinned by digest.";
      };
      logDir = mkOption {
        type = types.str;
        default = "/var/log/mosquitto";
        description = "Location to store Mosquitto logs.";
      };
      port = mkOption {
        type = types.port;
        default = 1883;
        description = "MQTT listener port.";
      };
      bindAddress = mkOption {
        type = types.str;
        default = "127.0.0.1";
        example = "0.0.0.0";
        description = "Address on which the MQTT broker listens.";
      };
      allowAnonymous = mkOption {
        type = types.bool;
        default = true;
        example = false;
        description = "Whether the MQTT broker accepts unauthenticated clients. Safe by default with the loopback-only bind address.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.confDir} 0755 root root -"
    ]
    ++ lib.optionals cfg.zigbee2mqtt.enable [
      "d ${cfg.zigbee2mqtt.dataDir} 0755 root root -"
    ]
    ++ lib.optionals cfg.mosquitto.enable [
      "d ${cfg.mosquitto.dataDir} 0755 1883 1883 -"
      "d ${cfg.mosquitto.logDir} 0755 1883 1883 -"
    ];

    virtualisation.oci-containers = {
      backend = "podman";
      containers.homeassistant = {
        volumes = [ "${cfg.confDir}:/config" ];
        environment.TZ = "Europe/Berlin";
        inherit (cfg) image;
        extraOptions = [
          # Use the host network namespace for all sockets
          "--network=host"
          # Pass devices into the container, so Home Assistant can discover and make use of them
          # "--device=/dev/ttyACM0:/dev/ttyACM0"
        ];
      };
      containers.zigbee2mqtt = lib.mkIf cfg.zigbee2mqtt.enable {
        image = cfg.zigbee2mqtt.image;
        volumes = [
          "${cfg.zigbee2mqtt.dataDir}:/app/data"
          "/run/udev:/run/udev:ro"
        ];
        environment.TZ = "Europe/Berlin";
        extraOptions = [
          "--network=host"
        ]
        ++ lib.optionals (cfg.zigbee2mqtt.adapter != null) [
          "--device=${cfg.zigbee2mqtt.adapter}:/dev/ttyACM0"
        ];
      };
      containers.mosquitto = lib.mkIf cfg.mosquitto.enable {
        image = cfg.mosquitto.image;
        volumes = [
          "${mosquittoConfig}:/mosquitto/config/mosquitto.conf:ro"
          "${cfg.mosquitto.dataDir}:/mosquitto/data"
          "${cfg.mosquitto.logDir}:/mosquitto/log"
        ];
        extraOptions = [
          "--network=host"
        ];
      };
    };
    # services.home-assistant = {
    #   enable = true;
    #   configDir = cfg.confDir;
    #   openFirewall = true;
    #   configWritable = true;
    #   lovelaceConfigWritable = true;
    #   config = {
    #     home-assistant = {
    #       time_zone = "Europe/Oslo";
    #       unit-system = "metric";
    #       temperature_unit = "C";
    #     };
    #     http = {
    #       server_port = 8123;
    #     };
    #   };
    # };

    # services.zigbee2mqtt = {
    #   enable = true;
    #   dataDir = "/var/lib/zigbee2mqtt";
    #   settings = {
    #     homeassistant.enabled = config.services.home-assistant.enable;
    #     permit_join = true;
    #   };
    # };
    #
    # services.mosquitto = {
    #   enable = true;
    #   settings = {
    #     allow_anonymous = true;
    #     autosave_interval = 60;
    #     connection_messages = false;
    #     listener = 1883;
    #     per_listener_settings = false;
    #     persistence_location = /config;
    #   };
    # };
  };
}
