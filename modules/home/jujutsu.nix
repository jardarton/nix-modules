{ localFlake, withSystem, ... }:
{ pkgs
, lib
, config
, ...
}:
with lib;
let
  cfg = config.modules.home.jujutsu;
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

    home.packages = [
      pkgs.lazyjj
    ] ++ optionals cfg.jjStarship.enable [
      cfg.jjStarship.package
    ];

    home.shellAliases = {
      jj = lib.getExe pkgs.jujutsu;
      lazyjj = lib.getExe pkgs.lazyjj;
      lj = lib.getExe pkgs.lazyjj;
    };
  };
}
