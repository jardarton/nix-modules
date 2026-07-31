{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.modules.home.jujutsu;
  zshEnabled = lib.attrByPath [ "modules" "home" "zsh" "enable" ] false config;
  jjZshCompletion = pkgs.runCommand "jj-zsh-completion" { } ''
    mkdir -p "$out/share/zsh/site-functions"
    COMPLETE=zsh ${lib.getExe pkgs.jujutsu} > "$out/share/zsh/site-functions/_jj"
  '';
in
{
  options.modules.home.jujutsu = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "enable jujutsu";
    };

    hunkPackage = lib.mkOption {
      type = lib.types.package;
      description = "Hunk package used as the Jujutsu pager.";
    };

    userName = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "Jane Doe";
      description = "Name to use for jujutsu commits.";
    };

    userEmail = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "jane@example.com";
      description = "Email to use for jujutsu commits.";
    };

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      example = lib.literalExpression ''
        {
          ui.default-command = "log";
        }
      '';
      description = "Additional jujutsu settings.";
    };

    jjStarship = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        example = false;
        description = "Install jj-starship and configure Starship integration.";
      };

      package = lib.mkOption {
        type = lib.types.package;
        description = "jj-starship package to install.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.jujutsu = {
      enable = true;
      package = pkgs.jujutsu;
      settings = lib.mkMerge [
        (lib.mkIf (cfg.userName != null || cfg.userEmail != null) {
          user = lib.mkMerge [
            (lib.mkIf (cfg.userName != null) { name = cfg.userName; })
            (lib.mkIf (cfg.userEmail != null) { email = cfg.userEmail; })
          ];
        })
        {
          ui.default-command = "log";
          ui.pager = [
            "${cfg.hunkPackage}/bin/hunk"
            "pager"
          ];
          ui.diff-formatter = ":git";
        }
        cfg.settings
      ];
    };

    programs.starship.settings = lib.mkIf cfg.jjStarship.enable {
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

    home.packages =
      lib.optionals cfg.jjStarship.enable [
        cfg.jjStarship.package
      ]
      ++ lib.optionals zshEnabled [
        jjZshCompletion
      ];

    home.shellAliases = {
      jj = lib.getExe pkgs.jujutsu;
      jui = lib.getExe pkgs.jjui;
      lj = lib.getExe pkgs.jjui;
    };
  };
}
