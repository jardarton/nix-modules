{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.nixos.disk-monitor;
  hostname = lib.escapeShellArg config.networking.hostName;
  mountPoint = lib.escapeShellArg cfg.mountPoint;
  ntfyUrl = lib.escapeShellArg cfg.ntfyUrl;

  diskMonitor = pkgs.writeShellApplication {
    name = "disk-space-monitor";
    runtimeInputs = with pkgs; [
      coreutils
      curl
    ];
    text = ''
      state_file="$STATE_DIRECTORY/level"
      hostname=${hostname}
      mount_point=${mountPoint}
      ntfy_url=${ntfyUrl}

      read -r space_raw inode_raw < <(df --output=pcent,ipcent "$mount_point" | tail -n 1)
      space_pct=$(printf '%s' "$space_raw" | tr -d '%')
      inode_pct=$(printf '%s' "$inode_raw" | tr -d '%')
      read -r free_human < <(df -h --output=avail "$mount_point" | tail -n 1)

      level=0
      if (( space_pct >= ${toString cfg.criticalThreshold} || inode_pct >= ${toString cfg.criticalThreshold} )); then
        level=2
      elif (( space_pct >= ${toString cfg.warningThreshold} || inode_pct >= ${toString cfg.warningThreshold} )); then
        level=1
      fi

      previous=""
      if [[ -f "$state_file" ]]; then
        read -r previous < "$state_file" || true
      fi

      if [[ "$previous" == "$level" ]]; then
        exit 0
      fi

      # Establish a healthy baseline without sending noise after deployment.
      if [[ -z "$previous" && "$level" == 0 ]]; then
        printf '%s\n' "$level" > "$state_file"
        exit 0
      fi

      case "$level" in
        2)
          status="CRITICAL"
          priority="urgent"
          ;;
        1)
          status="WARNING"
          priority="high"
          ;;
        *)
          status="RECOVERED"
          priority="default"
          ;;
      esac

      message="$status: $hostname $mount_point is $space_pct% full ($free_human free); inode usage is $inode_pct%."
      curl -fsS --retry 3 \
        -H "Title: Disk usage on $hostname" \
        -H "Priority: $priority" \
        -d "$message" \
        "$ntfy_url"

      # Only latch the new level after notification succeeds, so failures retry.
      printf '%s\n' "$level" > "$state_file"
    '';
  };
in
{
  options.modules.nixos.disk-monitor = {
    enable = lib.mkEnableOption "lightweight disk usage monitoring with ntfy alerts";

    mountPoint = lib.mkOption {
      type = lib.types.str;
      default = "/";
      description = "Filesystem mount point to monitor.";
    };

    ntfyUrl = lib.mkOption {
      type = lib.types.str;
      example = "https://ntfy.sh/my-topic";
      description = ''
        ntfy topic URL that receives disk and Nix garbage collection alerts.
        This has no default because every deployment posts to its own topic.
      '';
    };

    warningThreshold = lib.mkOption {
      type = lib.types.ints.between 1 99;
      default = 80;
      description = "Disk or inode usage percentage that triggers a warning.";
    };

    criticalThreshold = lib.mkOption {
      type = lib.types.ints.between 2 100;
      default = 90;
      description = "Disk or inode usage percentage that triggers a critical alert.";
    };

    interval = lib.mkOption {
      type = lib.types.str;
      default = "5m";
      description = "systemd time span between two usage checks.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.warningThreshold < cfg.criticalThreshold;
        message = "disk-monitor warningThreshold must be below criticalThreshold";
      }
    ];

    systemd.services.disk-space-monitor = {
      description = "Monitor disk and inode usage";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${diskMonitor}/bin/disk-space-monitor";
        StateDirectory = "disk-space-monitor";
      };
    };

    systemd.timers.disk-space-monitor = {
      description = "Check disk and inode usage on a fixed interval";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "2m";
        OnUnitActiveSec = cfg.interval;
        AccuracySec = "30s";
      };
    };

    systemd.services.nix-gc.onFailure = [ "nix-gc-failed-notify.service" ];

    systemd.services.nix-gc-failed-notify = {
      description = "Notify when Nix garbage collection fails";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      script = ''
        ${pkgs.curl}/bin/curl -fsS --retry 3 \
          -H ${lib.escapeShellArg "Title: Nix GC failed on ${config.networking.hostName}"} \
          -H "Priority: urgent" \
          -d ${lib.escapeShellArg "Nix garbage collection failed on ${config.networking.hostName}. Check: journalctl -u nix-gc.service"} \
          ${ntfyUrl}
      '';
      serviceConfig.Type = "oneshot";
    };
  };
}
