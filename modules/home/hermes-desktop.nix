{ localFlake, withSystem, ... }:
{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.modules.home.hermes-desktop;
in
{
  options.modules.home.hermes-desktop = {
    enable = lib.mkEnableOption "Hermes Desktop";

    remoteUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "http://100.78.133.19:9119";
      description = "Remote Hermes dashboard backend URL. Leave null to use the app's saved setting/local backend.";
    };
  };

  config = lib.mkIf cfg.enable (
    let
      hermesDesktop = withSystem pkgs.stdenv.hostPlatform.system (
        { system, ... }:
        localFlake.inputs.hermes-agent.packages.${system}.desktop
      );
    in
    {
      home.packages = [ hermesDesktop ];

      home.sessionVariables = lib.mkIf (cfg.remoteUrl != null) {
        HERMES_DESKTOP_REMOTE_URL = cfg.remoteUrl;
      };

      xdg.desktopEntries.hermes-desktop = {
        name = "Hermes Desktop";
        genericName = "AI Agent";
        comment = "Hermes Agent desktop app";
        exec = lib.concatStringsSep " " (
          lib.optional (cfg.remoteUrl != null) "env HERMES_DESKTOP_REMOTE_URL=${lib.escapeShellArg cfg.remoteUrl}"
          ++ [ (lib.getExe hermesDesktop) ]
        );
        terminal = false;
        categories = [ "Development" "Utility" ];
      };
    }
  );
}
