{ localFlake, withSystem, ... }:
{ config
, lib
, pkgs
, ...
}:
with lib;
let
  cfg = config.modules.home.ai;
  agentOptions =
    { name
    , packageName ? name
    , default ? true
    , description ? "install ${name}"
    ,
    }:
    {
      enable = mkOption {
        type = types.bool;
        inherit default;
        example = true;
        description = description;
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

    pi = agentOptions { name = "pi"; };

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

    home.packages = withSystem pkgs.stdenv.hostPlatform.system (
      { pkgs, system, ... }:
      let
        llmPackages = localFlake.inputs.llm-agents.packages.${system};
        packageOr =
          agentCfg: defaultPackage: if agentCfg.package != null then agentCfg.package else defaultPackage;
      in
      optional cfg.pi.enable (packageOr cfg.pi llmPackages.pi)
      ++ optional cfg.claude.enable (packageOr cfg.claude llmPackages.claude-code)
      ++ optional cfg.codex.enable (packageOr cfg.codex pkgs.codex)
      ++ optional cfg.opencode.enable (packageOr cfg.opencode llmPackages.opencode)
      ++ optional cfg.copilot-cli.enable (packageOr cfg.copilot-cli llmPackages.copilot-cli)
      ++ optional cfg.playwright-cli.enable (packageOr cfg.playwright-cli localFlake.packages.${system}.playwright-cli)
      ++ optional cfg.agentBrowser llmPackages.agent-browser
    );

  };
}
