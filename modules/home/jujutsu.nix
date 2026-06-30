{ localFlake, withSystem, ... }:
{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.home.jujutsu;
  hunk = localFlake.inputs.hunk.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  options.modules.home.jujutsu = {
    enable = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = "enable jujutsu";
    };

    userName = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "Jane Doe";
      description = "Name to use for jujutsu commits.";
    };

    userEmail = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "jane@example.com";
      description = "Email to use for jujutsu commits.";
    };

    settings = mkOption {
      type = types.attrs;
      default = { };
      example = literalExpression ''
        {
          ui.default-command = "log";
        }
      '';
      description = "Additional jujutsu settings.";
    };

    jjStarship = {
      enable = mkOption {
        type = types.bool;
        default = true;
        example = false;
        description = "Install jj-starship and configure Starship integration.";
      };

      package = mkOption {
        type = types.package;
        default = withSystem pkgs.stdenv.hostPlatform.system (
          { system, ... }:
          localFlake.inputs.jj-starship.packages.${system}.default
        );
        defaultText = literalExpression "localFlake.inputs.jj-starship.packages.\${pkgs.stdenv.hostPlatform.system}.default";
        description = "jj-starship package to install.";
      };
    };
  };

  config = mkIf cfg.enable {
    programs.jujutsu = {
      enable = true;
      package = pkgs.jujutsu;
      settings = mkMerge [
        (mkIf (cfg.userName != null || cfg.userEmail != null) {
          user = mkMerge [
            (mkIf (cfg.userName != null) { name = cfg.userName; })
            (mkIf (cfg.userEmail != null) { email = cfg.userEmail; })
          ];
        })
        {
          ui.default-command = "log";
          ui.pager = [
            "${hunk}/bin/hunk"
            "pager"
          ];
          ui.diff-formatter = ":git";
        }
        cfg.settings
      ];
    };

    programs.starship.settings = mkIf cfg.jjStarship.enable {
      custom.jj = {
        when = "jj-starship detect";
        shell = [ "jj-starship" ];
        format = "$output ";
      };
    };

    programs.jjui = {
      enable = true;
      settings = {
        ui = {
          mouse_support = true;
          auto_refresh_interval = 0;
        };
        preview = {
          position = "auto";
          show_at_start = false;
          width_percentage = 50.0;
        };
        revisions = {
          log_batching = true;
          log_batch_size = 50;
        };
      };
    };

    home.packages = optionals cfg.jjStarship.enable [
      cfg.jjStarship.package
    ];

    home.shellAliases = {
      jj = lib.getExe pkgs.jujutsu;
      jui = lib.getExe pkgs.jjui;
      lj = lib.getExe pkgs.jjui;
    };
  };
}
