{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.cli-proxy-api;
  yaml = pkgs.formats.yaml { };
  baseConfig = yaml.generate "cli-proxy-api-base.yaml" (
    cfg.settings
    // {
      server = (cfg.settings.server or { }) // {
        inherit (cfg) port;
      };
      oauth = (cfg.settings.oauth or { }) // {
        auth-dir = "/var/lib/cli-proxy-api/auth";
      };
    }
  );
in
{
  options.services.cli-proxy-api = {
    enable = lib.mkEnableOption "CLIProxyAPI service";
    package = lib.mkOption {
      type = lib.types.package;
      description = "CLIProxyAPI package (for example, from llm-agents.nix).";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8317;
      description = "Port for the API listener.";
    };
    settings = lib.mkOption {
      inherit (yaml) type;
      default = { };
      description = "Non-secret CLIProxyAPI configuration. Client API key is generated in the service state directory; do not set access here.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !(cfg.settings ? access);
        message = "services.cli-proxy-api.settings.access is not supported; the service generates a private client key.";
      }
    ];
    systemd.services.cli-proxy-api = {
      description = "CLIProxyAPI";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      preStart = ''
        umask 077
        mkdir -p "$STATE_DIRECTORY/auth"
        if [ ! -s "$STATE_DIRECTORY/api-key" ]; then
          ${pkgs.openssl}/bin/openssl rand -hex 32 > "$STATE_DIRECTORY/api-key"
        fi
        cp ${baseConfig} "$STATE_DIRECTORY/config.yaml"
        chmod 600 "$STATE_DIRECTORY/config.yaml"
        printf '\naccess:\n  api-keys:\n    - ' >> "$STATE_DIRECTORY/config.yaml"
        ${pkgs.jq}/bin/jq -R . < "$STATE_DIRECTORY/api-key" >> "$STATE_DIRECTORY/config.yaml"
      '';
      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        StateDirectory = "cli-proxy-api";
        StateDirectoryMode = "0700";
        WorkingDirectory = "/var/lib/cli-proxy-api";
        ExecStart = "${lib.getExe cfg.package} --config /var/lib/cli-proxy-api/config.yaml";
        Restart = "on-failure";
        UMask = "0077";
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
      };
    };
  };
}
