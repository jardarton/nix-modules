{ localFlake, withSystem, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.home.ai;
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
  };

  config = mkIf cfg.enable {

    home.packages = withSystem pkgs.stdenv.hostPlatform.system (
      { pkgs, system, ... }:
      let
        llmPackages = localFlake.inputs.llm-agents.packages.${system};
      in
      (with llmPackages; [
        claude-code
        opencode
        pi
        copilot-cli
      ])
      ++ [ pkgs.codex ]
      ++ optional cfg.agentBrowser llmPackages.agent-browser
    );

  };
}
