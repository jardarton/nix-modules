{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.home.ai;
  agentOptions =
    {
      name,
      packageName ? name,
      default ? true,
      description ? "install ${name}",
    }:
    {
      enable = mkOption {
        type = types.bool;
        inherit default;
        example = true;
        inherit description;
      };

      package = mkOption {
        type = types.nullOr types.package;
        default = null;
        defaultText = literalExpression packageName;
        description = "package to use for ${name}; null uses the module default";
      };
    };
in
{

  imports = [ ./claude.nix ];

  options.modules.home.ai = {
    enable = mkOption {
      type = types.bool;
      default = true;
      example = true;
      description = "enable ai packages";
    };

    agentBrowser = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = "install the agent-browser package";
    };

    defaultPackages = mkOption {
      type = types.attrsOf types.package;
      internal = true;
      description = "Default AI tool packages supplied by the feature module.";
    };

    claude = agentOptions {
      name = "claude";
      packageName = "claude-code";
    };

    codex = agentOptions { name = "codex"; };

    opencode = agentOptions { name = "opencode"; };

    copilot-cli = agentOptions {
      name = "copilot-cli";
      packageName = "copilot-cli";
    };

    playwright-cli = agentOptions {
      name = "playwright-cli";
      packageName = "playwright-cli";
    };
  };

  config = mkIf cfg.enable {

    home.sessionVariables =
      let
        system = pkgs.stdenv.hostPlatform.system;
        playwrightBrowser =
          if
            elem system [
              "x86_64-linux"
              "x86_64-darwin"
              "aarch64-darwin"
            ]
          then
            pkgs.google-chrome
          else
            pkgs.chromium;
      in
      mkIf cfg.playwright-cli.enable {
        PLAYWRIGHT_MCP_EXECUTABLE_PATH = getExe playwrightBrowser;
      };

    home.packages =
      let
        system = pkgs.stdenv.hostPlatform.system;
        packageOr =
          agentCfg: defaultPackage: if agentCfg.package != null then agentCfg.package else defaultPackage;
        playwrightBrowser =
          if
            elem system [
              "x86_64-linux"
              "x86_64-darwin"
              "aarch64-darwin"
            ]
          then
            pkgs.google-chrome
          else
            pkgs.chromium;
      in
      optional cfg.claude.enable (packageOr cfg.claude cfg.defaultPackages.claude)
      ++ optional cfg.codex.enable (packageOr cfg.codex cfg.defaultPackages.codex)
      ++ optional cfg.opencode.enable (packageOr cfg.opencode cfg.defaultPackages.opencode)
      ++ optional cfg.copilot-cli.enable (packageOr cfg.copilot-cli cfg.defaultPackages.copilot-cli)
      ++ optionals cfg.playwright-cli.enable [
        (packageOr cfg.playwright-cli cfg.defaultPackages.playwright-cli)
        playwrightBrowser
      ]
      ++ optional cfg.agentBrowser cfg.defaultPackages.agent-browser;

  };
}
