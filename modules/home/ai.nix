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
  };

  config = mkIf cfg.enable {

    home.packages = withSystem pkgs.stdenv.hostPlatform.system (
      { pkgs, system, ... }:
      [ ]
      ++ (with localFlake.inputs.llm-agents.packages.${system}; [
        claude-code
        opencode
        pi
        mcporter
        workmux
        codex
        copilot-cli
        agent-browser
      ])
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
