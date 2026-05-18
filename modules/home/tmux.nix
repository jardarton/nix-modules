{ localFlake, ... }:
{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.home.tmux;
  televisionEnabled = attrByPath [ "modules" "home" "television" "enable" ] false config;
  televisionCableDir = "$HOME/.config/television/cable";
in
{

  options.modules.home.tmux = {
    enable = mkOption {
      type = types.bool;
      default = true;
      example = true;
      description = "enable tmux";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      fzf
      fd
      tmuxPlugins.continuum # needs to be last in config; so adding it here
    ];

    stylix.targets.tmux.enable = false;

    home.sessionPath = [
      "$HOME/.local/scripts"
    ];
    home.file.".local/scripts/tmux-sessionizer" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash

        if [[ $# -eq 1 ]]; then
            selected=$1
        else
            selected=$(fd . ~ -t d -d 3 -H -E Applications -E Library -E Music -E Movies -E Pictures -E Downloads -E Desktop -E Documents | fzf)
        fi

        if [[ -z $selected ]]; then
            exit 0
        fi

        selected_name=$(basename "$selected" | tr . _)
        tmux_running=$(pgrep tmux)

        if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
            tmux new-session -s $selected_name -c $selected
            exit 0
        fi

        if ! tmux has-session -t=$selected_name 2> /dev/null; then
            tmux new-session -ds $selected_name -c $selected
        fi

        if [[ -z $TMUX ]]; then
            tmux attach -t $selected_name
        else
            tmux switch-client -t $selected_name
        fi
      '';
    };

    home.file.".local/scripts/tv-git-worktree-common" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash

        set -euo pipefail

        normalize_path() {
          local path

          path=$1
          if [[ -d $path ]]; then
            (
              cd "$path"
              pwd -P
            )
          else
            (
              cd "$(dirname "$path")"
              printf '%s/%s\n' "$(pwd -P)" "$(basename "$path")"
            )
          fi
        }

        in_git_repo() {
          git rev-parse --show-toplevel >/dev/null 2>&1
        }

        repo_root_from_cwd() {
          git rev-parse --show-toplevel
        }

        main_worktree_for_path() {
          local worktree common_dir

          worktree=$(normalize_path "$1")
          common_dir=$(git -C "$worktree" rev-parse --path-format=absolute --git-common-dir)
          normalize_path "$(dirname "$common_dir")"
        }

        repo_name_for_path() {
          basename "$(main_worktree_for_path "$1")"
        }

        branch_for_path() {
          local worktree branch

          worktree=$(normalize_path "$1")
          if branch=$(git -C "$worktree" symbolic-ref --quiet --short HEAD 2>/dev/null); then
            printf '%s\n' "$branch"
          else
            git -C "$worktree" rev-parse --short HEAD
          fi
        }

        session_name_for_path() {
          local target normalized sessions

          target=$(normalize_path "$1")
          sessions=$(tmux list-sessions -F '#{session_name}\t#{session_path}' 2>/dev/null || true)
          while IFS=$'\t' read -r session_name session_path; do
            [[ -n ''${session_name:-} ]] || continue
            if [[ $(normalize_path "$session_path") == "$target" ]]; then
              printf '%s\n' "$session_name"
              return 0
            fi
          done <<< "$sessions"
          return 1
        }

        next_session_name() {
          local worktree repo_name base candidate suffix

          worktree=$(normalize_path "$1")
          repo_name=$(repo_name_for_path "$worktree")
          base=$(basename "$worktree" | tr -cs '[:alnum:]._' '-')
          base=$''${base#-}
          base=$''${base%-}
          if [[ -z $base ]]; then
            base=$repo_name
          fi
          candidate=$base
          if [[ $candidate == "$repo_name" ]]; then
            candidate="$repo_name-main"
          fi
          suffix=2
          while tmux has-session -t "$candidate" 2>/dev/null; do
            candidate="$base-$suffix"
            suffix=$((suffix + 1))
          done
          printf '%s\n' "$candidate"
        }

        ensure_session_for_path() {
          local worktree session_name

          worktree=$(normalize_path "$1")
          if session_name=$(session_name_for_path "$worktree"); then
            printf '%s\n' "$session_name"
            return 0
          fi

          session_name=$(next_session_name "$worktree")
          tmux new-session -d -s "$session_name" -c "$worktree"
          printf '%s\n' "$session_name"
        }

        attach_or_switch_session() {
          local session_name

          session_name=$1
          if [[ -n ''${TMUX:-} ]]; then
            exec tmux switch-client -t "$session_name"
          else
            exec tmux attach-session -t "$session_name"
          fi
        }
      '';
    };

    home.file.".local/scripts/tv-git-worktree-list" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash

        set -euo pipefail
        source "$HOME/.local/scripts/tv-git-worktree-common"

        if ! in_git_repo; then
          exit 0
        fi

        repo_root=$(repo_root_from_cwd)
        main_worktree=$(main_worktree_for_path "$repo_root")

        current_path=
        current_branch=

        emit_current() {
          local path branch session_name label session_status

          path=$1
          branch=$2
          session_status='no tmux'
          if session_name=$(session_name_for_path "$path" 2>/dev/null); then
            session_status="$session_name"
          fi

          label=$(basename "$path")
          if [[ $(normalize_path "$path") == "$main_worktree" ]]; then
            label="$label (main)"
          fi

          printf '%s\t%s\t%s\t%s\n' "$label" "$branch" "$session_status" "$path"
        }

        while IFS= read -r line; do
          if [[ -z $line ]]; then
            if [[ -n $current_path ]]; then
              emit_current "$current_path" "$current_branch"
            fi
            current_path=
            current_branch=
            continue
          fi

          case $line in
            worktree\ *)
              current_path=$(normalize_path "''${line#worktree }")
              ;;
            branch\ refs/heads/*)
              current_branch=''${line#branch refs/heads/}
              ;;
            detached)
              current_branch=$(git -C "$current_path" rev-parse --short HEAD)
              ;;
          esac
        done < <(git -C "$repo_root" worktree list --porcelain && printf '\n')
      '';
    };

    home.file.".local/scripts/tv-git-worktree-preview" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash

        set -euo pipefail
        source "$HOME/.local/scripts/tv-git-worktree-common"

        worktree=$(normalize_path "$1")

        if session_name=$(session_name_for_path "$worktree" 2>/dev/null); then
          tmux_status=$session_name
        else
          tmux_status='no tmux session'
        fi

        printf 'Path: %s\n' "$worktree"
        printf 'Branch: %s\n' "$(branch_for_path "$worktree")"
        printf 'Tmux: %s\n' "$tmux_status"
        printf '\nRecent commits\n\n'
        git -C "$worktree" --no-pager log --oneline -10 --color=always
        printf '\nStatus\n\n'
        git -C "$worktree" --no-pager status --short
      '';
    };

    home.file.".local/scripts/tv-git-worktree-enter" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash

        set -euo pipefail
        source "$HOME/.local/scripts/tv-git-worktree-common"

        if [[ $# -ne 1 ]]; then
          printf 'usage: %s <worktree-path>\n' "$0" >&2
          exit 1
        fi

        worktree=$(normalize_path "$1")
        session_name=$(ensure_session_for_path "$worktree")
        attach_or_switch_session "$session_name"
      '';
    };

    home.file.".local/scripts/tv-git-worktree-create" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash

        set -euo pipefail
        source "$HOME/.local/scripts/tv-git-worktree-common"

        if ! in_git_repo; then
          printf 'Not inside a git repository.\n' >&2
          exit 1
        fi

        repo_root=$(repo_root_from_cwd)
        repo_root=$(normalize_path "$repo_root")
        repo_parent=$(dirname "$repo_root")
        repo_name=$(basename "$repo_root")

        printf 'New worktree name: '
        read -r worktree_name < /dev/tty

        if [[ -z $worktree_name ]]; then
          printf 'Aborted: worktree name is required.\n' >&2
          exit 1
        fi

        if [[ ! $worktree_name =~ ^[A-Za-z0-9._-]+$ ]]; then
          printf 'Invalid name: use only letters, numbers, dot, underscore, or dash.\n' >&2
          exit 1
        fi

        target_path="$repo_parent/$repo_name-$worktree_name"
        if [[ -e $target_path ]]; then
          printf 'Target already exists: %s\n' "$target_path" >&2
          exit 1
        fi

        git -C "$repo_root" worktree add -b "$worktree_name" "$target_path"
        session_name=$(ensure_session_for_path "$target_path")
        attach_or_switch_session "$session_name"
      '';
    };

    home.file.".local/scripts/tv-git-worktree-delete" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash

        set -euo pipefail
        source "$HOME/.local/scripts/tv-git-worktree-common"

        if [[ $# -ne 1 ]]; then
          printf 'usage: %s <worktree-path>\n' "$0" >&2
          exit 1
        fi

        worktree=$(normalize_path "$1")
        main_worktree=$(main_worktree_for_path "$worktree")

        if [[ $worktree == "$main_worktree" ]]; then
          printf 'Refusing to remove the main worktree: %s\n' "$worktree" >&2
          exit 1
        fi

        repo_root=$main_worktree
        session_name=$(session_name_for_path "$worktree" 2>/dev/null || true)

        git -C "$repo_root" worktree remove "$worktree"

        if [[ -n $session_name ]]; then
          tmux kill-session -t "$session_name"
        fi
      '';
    };

    home.file.".config/tmux/session-fzf.sh" = {
      text = ''
        #!/usr/bin/env bash

        # Get a list of tmux sessions
        sessions=$(tmux list-sessions -F "#{session_name}")

        # Use fzf to select a session
        selected_session=$(echo "$sessions" | fzf --height=50 --reverse --border --prompt="Select tmux session: ")

        # If a session was selected, attach to it
        if [ -n "$selected_session" ]; then
            tmux switch-client -t "$selected_session"
        fi
      '';
      executable = true;
    };
    home.file.".config/tmux/session-tv-run.sh" = mkIf televisionEnabled {
      text = ''
        #!/usr/bin/env bash

        exec ${config.programs.television.package}/bin/tv \
          tmux-sessions \
          --cable-dir "${televisionCableDir}" \
          --no-remote \
          --no-help-panel \
          --input-header 'tmux sessions' \
          --input-prompt 'session> '
      '';
      executable = true;
    };
    home.file.".config/tmux/worktree-tv-run.sh" = mkIf televisionEnabled {
      text = ''
        #!/usr/bin/env bash

        exec ${config.programs.television.package}/bin/tv \
          git-worktrees \
          --cable-dir "${televisionCableDir}" \
          --no-remote \
          --no-help-panel \
          --input-header 'git worktrees' \
          --input-prompt 'worktree> '
      '';
      executable = true;
    };
    programs.tmux = {
      enable = true;
      aggressiveResize = true;
      clock24 = true;
      historyLimit = 30000;
      newSession = true;
      secureSocket = false;
      disableConfirmationPrompt = true;
      plugins = with pkgs.tmuxPlugins; [
        vim-tmux-navigator
        {
          plugin = battery;
        }
        yank
        {
          plugin = fuzzback;
          extraConfig = ''
            unbind /
            set -g @fuzzback-bind /
            set -g @fuzzback-popup 1
          '';
        }

        {
          plugin = resurrect;
          extraConfig = ''
            set -g @resurrect-capture-pane-contents 'on' # allow tmux-ressurect to capture pane contents
            set -g @resurrect-strategy-nvim 'session'
          '';
        }
        {
          plugin = jump;
          extraConfig = ''
            unbind s
            set -g @jump-key 's'
          '';
        }
        {
          plugin = tmux-thumbs;
          extraConfig = ''
            set -g @thumbs-key 'f'
            set -g @thumbs-alphabet dvorak-homerow
            set -g @thumbs-contrast 1
          '';
        }
        {
          plugin = tmux-floax;
          extraConfig = ''
            set -g @floax-bind 'r'
            set -g @floax-width '80%'
            set -g @floax-height '80%'
            set -g @floax-session-name 'floax'
            set -g @floax-title 'floax'
          '';
        }
      ];
      keyMode = "vi";
      terminal = "tmux-256color";
      mouse = true;
      extraConfig = ''
        set -as terminal-features ",tmux-256color:RGB"
        set -as terminal-features ",tmux-256color:extkeys"
        set -as terminal-features ",xterm-kitty:RGB"
        set -as terminal-features ",xterm-kitty:extkeys"
        set -as terminal-features ",xterm-ghostty:RGB"
        set -as terminal-features ",xterm-ghostty:extkeys"

        ############# SESSIONS ######################

        ${optionalString televisionEnabled "bind-key 'tab' run-shell \"tmux popup -w 100% -h 100% -E '$HOME/.config/tmux/session-tv-run.sh'\""}
        ${optionalString (
          !televisionEnabled
        ) "bind-key 'tab' run-shell \"tmux popup -w 100% -h 100% -E '$HOME/.config/tmux/session-fzf.sh'\""}
        ${optionalString televisionEnabled "bind-key 't' run-shell \"tmux popup -d '#{pane_current_path}' -w 100% -h 100% -E '$HOME/.config/tmux/worktree-tv-run.sh'\""}
        bind-key -r o run-shell "tmux neww ~/.local/scripts/tmux-sessionizer"

        unbind 'D'
        bind 'D' detach 

        # last session
        unbind 'A'
        bind 'A' switch-client -l

        unbind 'R'
        bind-key 'R' command-prompt -I "#S" "rename-session '%%'"

        bind-key 'Q' kill-server

        ############# WINDOWS ######################
        unbind '&'
        bind 'q' kill-window 

        unbind %
        bind 'v' split-window -h -c "#{pane_current_path}"

        unbind '"'
        bind 'b' split-window -v -c "#{pane_current_path}"

        # swap windows
        unbind 'P'
        unbind 'N'
        bind 'H' swap-window -t -1
        bind 'L' swap-window -t +1

        unbind 'c'
        bind 'c' new-window

        unbind 'a'
        bind 'a' last-window

        set -g renumber-windows on


        ############# PANES ######################

        unbind 'W'
        bind-key 'W' command-prompt -I "#W" "rename-window '%%'" 


        bind -r j resize-pane -D 10
        bind -r k resize-pane -U 10
        bind -r l resize-pane -R 10
        bind -r h resize-pane -L 10
        bind -r enter resize-pane -Z


        ########### TMUX ####################
        bind , source-file ~/.tmux.conf

        #bind-key -T copy-mode-vi 'v' send -X begin-selection # start selecting text with "v"
        #bind-key -T copy-mode-vi 'y' send -X copy-selection # copy text with "y"

        unbind -T copy-mode-vi MouseDragEnd1Pane # don't exit copy mode after dragging with mouse

        ###### BIND TO STYLIX COLORS ######
        set -g @thm_bg black
        set -g @thm_overlay_0 lightgray
        set -g @thm_surface_0 white
        set -g @thm_maroon lightblue
        set -g @thm_blue blue
        set -g @thm_yellow yellow
        set -g @thm_peach cyan
        set -g @thm_rosewater magenta
        set -g @thm_red red
        set -g @thm_green green

        set -ag message-style fg=yellow,blink; set-option -ag message-style bg=default

        # Configure Tmux
        set-option -sg escape-time 10
        set -g extended-keys on
        set -g focus-events on
        set -s set-clipboard on

        set -g status-position top
        set -g status-style "bg=default"
        set -g status-justify "absolute-centre"


        # status left look and feel
        set -g status-left-length 100
        set -g status-left ""
        set -ga status-left "#{?client_prefix,#{#[bg=#{@thm_red},fg=#{@thm_bg},bold]  #S },#{#[bg=default,fg=#{@thm_green}]  #S }}"
        set -ga status-left "#[bg=default,fg=lightgray,none]│"
        set -ga status-left "#[fg=lightblue]  #{pane_current_command} "
        set -ga status-left "#[fg=lightgray,none]│"
        set -ga status-left "#[fg=blue]  #{=/-32/...:#{s|$USER|~|:#{b:pane_current_path}}} "
        set -ga status-left "#[fg=lightgray,none]#{?window_zoomed_flag,│,}"
        set -ga status-left "#[fg=yellow]#{?window_zoomed_flag,  zoom ,}"

        # status right look and feel
        set -g status-right-length 100
        set -g status-right ""
        # set -g status-right "#(${pkgs.tmuxPlugins.continuum}/share/tmux-plugins/continuum/scripts/continuum_save.sh)"
        set -ga status-right '#[bg=default,fg=gray]SS: #{continuum_status}'
        set -ga status-right "#[fg=lightgray, none]│"
        set -ga status-right "#[fg=orange]  %Y-%m-%d  %H:%M "


        # pane border look and feel
        setw -g pane-border-status top
        setw -g pane-border-format ""
        setw -g pane-active-border-style "bg=default,fg=#{@thm_overlay_0}"
        setw -g pane-border-style "bg=default,fg=#{@thm_surface_0}"
        setw -g pane-border-lines single

        # window look and feel
        set -wg automatic-rename on
        set -g automatic-rename-format "term"

        set -g window-status-format " #I#{?#{!=:#{window_name},Window},: #W,} "
        set -g window-status-style "fg=lightgray"
        set -g window-status-last-style "fg=lightgreen"
        set -g window-status-activity-style "fg=orange"
        set -g window-status-bell-style "fg=red,bold"
        set -gF window-status-separator "#[fg=lightgray]│"

        set -g window-status-current-format " #I#{?#{!=:#{window_name},Window},: #W,} "
        set -g window-status-current-style "bg=default,fg=green,bold"


        #tmux navigator
        #copied here to handle nixCats and tmux navigator interaction
        #regex in vim_pattern needs modifying for it to reccognize nixCats nvim as vim program
        #this has added optonal (cats) as prefix to vi/vim/nvim
        vim_pattern='(\S+/)?g?\.?(cats)?(?:.*?)?(view|l?n?vim?x?|fzf)(diff)?(-wrapped)?'
        is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
            | grep -iqE '^[^TXZ ]+ +''${vim_pattern}$'"
        bind-key -n 'C-h' if-shell "$is_vim" { send-keys C-h } { if-shell -F '#{pane_at_left}'   {} { select-pane -L } }
        bind-key -n 'C-j' if-shell "$is_vim" { send-keys C-j } { if-shell -F '#{pane_at_bottom}' {} { select-pane -D } }
        bind-key -n 'C-k' if-shell "$is_vim" { send-keys C-k } { if-shell -F '#{pane_at_top}'    {} { select-pane -U } }
        bind-key -n 'C-l' if-shell "$is_vim" { send-keys C-l } { if-shell -F '#{pane_at_right}'  {} { select-pane -R } }

        bind-key -T copy-mode-vi 'C-h' if-shell -F '#{pane_at_left}'   {} { select-pane -L }
        bind-key -T copy-mode-vi 'C-j' if-shell -F '#{pane_at_bottom}' {} { select-pane -D }
        bind-key -T copy-mode-vi 'C-k' if-shell -F '#{pane_at_top}'    {} { select-pane -U }
        bind-key -T copy-mode-vi 'C-l' if-shell -F '#{pane_at_right}'  {} { select-pane -R }



        set -g @continuum-restore 'on' # enable tmux-continuum functionality
        set -g @continuum-save-interval '15'
        run-shell ${pkgs.tmuxPlugins.continuum}/share/tmux-plugins/continuum/continuum.tmux
      '';

    };
  };
}
