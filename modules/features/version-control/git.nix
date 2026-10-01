{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.home.git;
in
{
  options.modules.home.git = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = true;
      description = "Whether to enable Git and related tools.";
    };

    hunk.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to install Hunk and use it as the Git diff pager.";
    };

    hunkPackage = lib.mkOption {
      type = lib.types.package;
      description = "Hunk package used as the Git pager.";
    };

    worktrunk = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to install Worktrunk for Git worktree management.";
      };

      package = lib.mkOption {
        type = lib.types.package;
        description = "Worktrunk package to install.";
      };

      copyIgnored.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether to copy ignored files selected by a repository's
          .worktreeinclude into newly created worktrees. Repositories without
          .worktreeinclude are left untouched.
        '';
      };

      shellIntegration.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether to enable Worktrunk's Zsh integration so commands such as
          wt switch can change the current shell's working directory.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {

    programs.git = {
      enable = lib.mkDefault true;
      attributes = [
        "* merge=mergiraf"
      ];
      settings = {
        core.pager = lib.mkIf cfg.hunk.enable "${cfg.hunkPackage}/bin/hunk pager";
        pull.rebase = true;
      };
    };

    programs.gh = {
      enable = true;
      gitCredentialHelper.enable = true;
    };

    home.packages = [
      pkgs.git
      pkgs.gh
      pkgs.gh-dash
      pkgs.mergiraf
      pkgs.difftastic
    ]
    ++ lib.optional cfg.hunk.enable cfg.hunkPackage
    ++ lib.optional cfg.worktrunk.enable cfg.worktrunk.package;

    xdg.configFile."worktrunk/config.toml" =
      lib.mkIf (cfg.worktrunk.enable && cfg.worktrunk.copyIgnored.enable)
        {
          text = ''
            [post-start]
            copy-ignored = "wt step copy-ignored --require-include"
          '';
        };

    programs.zsh.initContent =
      lib.mkIf (cfg.worktrunk.enable && cfg.worktrunk.shellIntegration.enable)
        ''
          eval "$(${lib.getExe cfg.worktrunk.package} config shell init zsh)"
        '';

    programs.lazygit = {
      enable = true;
      settings = {
        gui = {
          border = "rounded";
        };
        git = {
          diffRenderers = [
            {
              type = "extDiff";
              command = "${pkgs.difftastic}/bin/difft --color=always --display=inline";
            }
          ];
        };
      };
    };
    home.shellAliases = {
      hunk = lib.mkIf cfg.hunk.enable "${cfg.hunkPackage}/bin/hunk";
      lg = "lazygit";
    };
  };
}
