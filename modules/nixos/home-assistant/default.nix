{ ... }:
{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.nixos.home-assistant;
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
  };

  config = lib.mkIf cfg.enable {

    virtualisation.oci-containers = {
      backend = "podman";
      containers.homeassistant = {
        volumes = [ "home-assistant:/config" ];
        environment.TZ = "Europe/Berlin";
        # Note: The image will not be updated on rebuilds, unless the version label changes
        image = "ghcr.io/home-assistant/home-assistant:stable";
        extraOptions = [
          # Use the host network namespace for all sockets
          "--network=host"
          # Pass devices into the container, so Home Assistant can discover and make use of them
          # "--device=/dev/ttyACM0:/dev/ttyACM0"
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
