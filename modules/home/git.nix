{ localFlake, withSystem, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.home.git;
  hunk = localFlake.inputs.hunk.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{

  options.modules.home.git = {
    enable = mkOption {
      type = types.bool;
      default = true;
      example = true;
      description = "enable git stuff";
    };
  };

  config = mkIf cfg.enable {

    programs.git = {
      attributes = [
        "* merge=mergiraf"
      ];
      settings = {
        core.pager = "${hunk}/bin/hunk pager";
      };
    };

    home.packages = withSystem pkgs.stdenv.hostPlatform.system (
      { system, config, ... }:
      [
        pkgs.git
        pkgs.gh
        pkgs.gh-dash
        pkgs.mergiraf
        pkgs.difftastic
        hunk
      ]
      ++ (with localFlake.inputs.llm-agents.packages.${system}; [
        but
      ])
    );

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
      hunk = "${hunk}/bin/hunk";
      lg = "lazygit";
    };
  };
}
