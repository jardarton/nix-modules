{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.nixos.laptop-base;
in
{
  options.modules.nixos.laptop-base = {
    enable = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = "Whether to enable base laptop settings.";
    };
    useTlp = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = "Whether to use TLP power management instead of power-profiles-daemon.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      pavucontrol
      brightnessctl
      pamixer
    ];

    services = {
      libinput = {
        enable = true;
        touchpad = {
          naturalScrolling = true;
          disableWhileTyping = true;
        };
      };

      power-profiles-daemon = mkIf (!cfg.useTlp) {
        enable = true;
      };
      upower.enable = lib.mkDefault true;
    };

    services.tlp = mkIf cfg.useTlp {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "powersave";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 70;

        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;
        CPU_HWP_DYN_BOOST_ON_AC = 1;
        CPU_HWP_DYN_BOOST_ON_BAT = 0;

        WIFI_PWR_ON_AC = "off";
        WIFI_PWR_ON_BAT = "on";

        SOUND_POWER_SAVE_ON_AC = 1;
        SOUND_POWER_SAVE_ON_BAT = 1;
        SOUND_POWER_SAVE_CONTROLLER = "Y";

        RUNTIME_PM_ON_AC = "on";
        RUNTIME_PM_ON_BAT = "auto";

        USB_AUTOSUSPEND = 1;
      };
    };
  };
}
