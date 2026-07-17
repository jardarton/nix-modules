{ withSystem, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.home.television;
  tmuxSessionsChannelText = ''
    [metadata]
    name = "tmux-sessions"
    description = "List and manage tmux sessions"
    requirements = ["tmux"]

    [source]
    command = "tmux list-sessions -F '#{session_name}\t#{session_windows} windows\t#{session_created_string}' | grep -v '^tv-tmux-sessions\t' | while IFS= read -r line; do printf '%s\t%s\n' \"$line\" \"$(date +%s)\"; done || true"
    watch = 1.0
    display = "{split:\t:0} ({split:\t:1})"
    output = "{split:\t:0}"

    [preview]
    command = "tmux capture-pane -p -J -S - -E - -t '{split:\t:0}:.' 2>/dev/null | tail -n 24 || echo 'No preview available'"
    cache_preview = false
    header = "Session: {split:\t:0}"

    [keybindings]
    ctrl-r = "reload_source"
    enter = "actions:attach"

    [actions.attach]
    description = "Attach to the selected session"
    command = "tmux switch-client -t '{split:\t:0}'"
    mode = "execute"

    [actions.kill]
    description = "Kill the selected session"
    command = "tmux kill-session -t '{split:\t:0}'"
    mode = "fork"
  '';
  gitWorktreesChannelText = ''
    [metadata]
    name = "git-worktrees"
    description = "List and manage git worktrees with tmux sessions"
    requirements = ["git", "tmux"]

    [source]
    command = "$HOME/.local/scripts/tv-git-worktree-list"
    watch = 1.0
    display = "{split:\t:0} ({split:\t:1}) [{split:\t:2}]"

    [preview]
    command = "$HOME/.local/scripts/tv-git-worktree-preview '{split:\t:3}'"
    header = "Worktree: {split:\t:0}"

    [keybindings]
    ctrl-r = "reload_source"
    enter = "actions:enter"
    ctrl-n = "actions:create"
    ctrl-d = "actions:delete"

    [actions.enter]
    description = "Enter the selected worktree session"
    command = "$HOME/.local/scripts/tv-git-worktree-enter '{split:\t:3}'"
    mode = "execute"

    [actions.create]
    description = "Create a new worktree and tmux session"
    command = "$HOME/.local/scripts/tv-git-worktree-create"
    mode = "execute"

    [actions.delete]
    description = "Delete the selected worktree and tmux session"
    command = "$HOME/.local/scripts/tv-git-worktree-delete '{split:\t:3}'"
    mode = "execute"
  '';
in
{
  options.modules.home.television = with lib; {
    enable = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = "enable television";
    };
  };

  config = lib.mkIf cfg.enable {
    home.file.".config/television/cable/tmux-sessions.toml".text = tmuxSessionsChannelText;
    home.file.".config/television/cable/git-worktrees.toml".text = gitWorktreesChannelText;

    programs.television = withSystem pkgs.stdenv.hostPlatform.system (_: {
      enable = true;
      enableZshIntegration = true;
      settings = {
        ui.theme = "gruvbox-dark";
      };
      channels.env = {
        metadata = {
          name = "env";
          description = "A channel to select from environment variables";
        };
        source = {
          command = "printenv";
          output = "{split:=:1..}";
        };
        preview.command = "echo '{split:=:1..}'";
        ui = {
          layout = "portrait";
          preview_panel = {
            size = 20;
            header = "{split:=:0}";
          };
        };
        keybindings.shortcut = "f3";
        actions.name = {
          description = "Output the variable name instead of the value";
          command = "echo '{split:=:0}'";
          mode = "execute";
        };
      };
    });
  };
}
