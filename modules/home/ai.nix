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
        mcporter
        workmux
        codex
        copilot-cli
        rtk
      ])
      ++ optional cfg.agentBrowser llmPackages.agent-browser
    );

    xdg.configFile."workmux/config.yaml".text = ''
      nerdfont: true
      merge_strategy: rebase
      agent: pi
      theme: default
      status_icons:
        working: "🗡️" # Agent is processing
        waiting: "🌙" # Agent needs input (auto-clears on focus)
        done: "👑" # Agent finished (auto-clears on focus)
      post_create:
        - direnv allow
      mode: session
      windows:
        - name: goblin
          panes:
            - command: <agent>
              focus: true
              zoom: true
            - split: horizontal
        - name: editor 
          panes:
            - name: nvim
            - split: horizontal
    '';
  };
}
