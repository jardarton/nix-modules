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

    hunkPackage = lib.mkOption {
      type = lib.types.package;
      description = "Hunk package used as the Git pager.";
    };
  };

  config = lib.mkIf cfg.enable {

    programs.git = {
      attributes = [
        "* merge=mergiraf"
      ];
      settings = {
        core.pager = "${cfg.hunkPackage}/bin/hunk pager";
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
      cfg.hunkPackage
    ];

    programs.lazygit = {
      enable = true;
      settings = {
        gui = {
          border = "rounded";
        };
        git = {
          pagers = [
            { externalDiffCommand = "${pkgs.difftastic}/bin/difft --color=always --display=inline"; }
          ];
        };
      };
    };
    home.shellAliases = {
      hunk = "${cfg.hunkPackage}/bin/hunk";
      lg = "lazygit";
    };
  };
}
