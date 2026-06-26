{ localFlake, ... }:
{ lib
, config
, pkgs
, ...
}:
with lib;
let
  cfg = config.modules.home.zsh;
  catsvimEnabled = attrByPath [ "modules" "home" "catsvim" "enable" ] false config;
  televisionEnabled = attrByPath [ "modules" "home" "television" "enable" ] false config;
  jujutsuEnabled = attrByPath [ "modules" "home" "jujutsu" "enable" ] false config;
  editor = if catsvimEnabled then "catsvim" else "nvim";
  clipboard = if pkgs.stdenv.hostPlatform.isDarwin then "pbcopy" else "wlcopy";
  zshSysClip =
    lib.optionalString pkgs.stdenv.hostPlatform.isLinux # sh
      ''
        export ZSH_SYSTEM_CLIPBOARD_USE_WL_CLIPBOARD="wl-clipboard"
      '';
in
{

  options.modules.home.zsh = {
    enable = mkOption {
      type = types.bool;
      default = true;
      example = true;
      description = "enable zsh";
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        neovim
        fzf
      ]
      ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
        wl-clipboard
      ];

    home.sessionPath = [
      "$HOME/.local/scripts"
      "$HOME/.local/bin"
    ];

    home.file.".local/scripts/fzf-cd" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash

        selected=$(fd . ~ -t d -d 3 -H -E Applications -E Library -E Music -E Movies -E Pictures -E Downloads -E Desktop -E Documents | fzf)

        if [[ $selected ]]; then
          cd "$selected"
        fi
      '';
    };

    programs.zsh = {
      enable = true;
      dotDir = "${config.xdg.configHome}/zsh";

      history = {
        append = true;
        expireDuplicatesFirst = true;
        size = 10000;
      };

      profileExtra = ''
        ${zshSysClip}
      '';

      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      historySubstringSearch.enable = true;

      initContent = ''
        DISABLE_AUTO_UPDATE="true"
        DISABLE_MAGIC_FUNCTIONS="true"
        DISABLE_COMPFIX="true"

        # Smarter completion initialization
        autoload -Uz compinit
        if [ "$(date +'%j')" != "$(stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)" ]; then
            compinit
        else
            compinit -C
        fi

        ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE="20"
        ZSH_AUTOSUGGEST_USE_ASYNC=1

        set -o inc_append_history

        export VISUAL="${editor}"
        export EDITOR="${editor}"

        ${lib.optionalString televisionEnabled ''
          eval "$(tv init zsh)"
        ''}
        ${lib.optionalString jujutsuEnabled ''
          source <(COMPLETE=zsh jj)
        ''}

        bindkey -M vicmd 'k' history-substring-search-up
        bindkey -M vicmd 'j' history-substring-search-down
        bindkey '^Y' autosuggest-accept
        bindkey -s ^o ". fzf-cd .\n"


        function zvm_config() {
        ZVM_CURSOR_STYLE_ENABLED=false
        }

        function zvm_custom_keybindings() {
        zvm_bindkey viins '^Y' autosuggest-accept
        ${lib.optionalString televisionEnabled "zvm_bindkey viins '^R' tv-shell-history"}
        ${lib.optionalString televisionEnabled "zvm_bindkey vicmd '^R' tv-shell-history"}
        ${lib.optionalString (!televisionEnabled) "zvm_bindkey viins '^R' fzf-history-widget"}
        ${lib.optionalString (!televisionEnabled) "zvm_bindkey vicmd '^R' fzf-history-widget"}
        }

        function zvm_vi_yank() {
          zvm_yank
          echo ''${CUTBUFFER} | ${clipboard}
          zvm_exit_visual_mode
        }

        function zvm_after_init() {
        zvm_custom_keybindings
        }

        function zvm_after_lazy_keybindings() {
        zvm_custom_keybindings
        }

        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
        zstyle ':completion:*' menu no
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

        path+=($HOME/.local/scripts/)
        path+=($HOME/.npm/bin)
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=3'
      '';

      plugins = [
        {
          name = "vi-mode";
          src = pkgs.zsh-vi-mode;
          file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
        }
        {
          name = "zsh-fzf-tab";
          src = pkgs.zsh-fzf-tab;
          file = "share/fzf-tab/fzf-tab.plugin.zsh";
        }
        {
          name = "zsh-system-clipboard";
          src = pkgs.zsh-system-clipboard;
          file = "share/zsh/zsh-system-clipboard/zsh-system-clipboard.zsh";
        }
      ];
    };

    programs.bash.enable = true;

    home.shellAliases = {
      ls = "ls --color";
      f = ''${editor} $(fzf --preview="bat --color=always {}")'';
    };
  };
}
