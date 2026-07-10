{ ... }:
{ pkgs
, config
, lib
, ...
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
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 40;

        # Optional helps save long term battery health
        START_CHARGE_THRESH_BAT0 = 40; # 40 and bellow it starts to charge
        STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging
      };
    };
  };
}
