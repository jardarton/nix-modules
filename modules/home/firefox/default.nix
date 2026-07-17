{ localFlake, withSystem, ... }:
{
  config,
  pkgs,
  lib,
  options,
  ...
}:
with lib;
let
  cfg = config.modules.home.firefox;
  stylix = import ../lib/stylix.nix { inherit config options; };
  textfox = localFlake.inputs.textfox;
  # Textfox reads its package output during evaluation without first realizing
  # the derivation. Force drvPath so Nix registers it before reading the output.
  textfoxModule = import "${textfox.outPath}/nix/modules/home-manager.nix" {
    self.packages = mapAttrs (
      _system: packages:
      packages
      // {
        default = builtins.seq packages.default.drvPath packages.default;
      }
    ) textfox.packages;
  };
in
{

  imports = [
    ./vimium.nix
    textfoxModule
  ];

  options.modules.home.firefox = {
    enable = mkOption {
      type = types.bool;
      default = true;
      example = true;
      description = "enable firefox";
    };
    profile = mkOption {
      type = types.str;
      default = "default";
      example = "default";
      description = "which profile";
    };
  };

  config = mkIf cfg.enable (
    {
      textfox = {
        enable = mkIf (cfg.profile == "default") true;
        profiles = [ cfg.profile ];
        config = {
          tabs = {
            horizontal.enable = false;
            vertical.enable = true;
          };
          icons = {
            toolbar.extensions.enable = true;
            context.extensions.enable = true;
            context.firefox.enable = true;
          };
          font = {
            # family = "Monaspace Krypton";
            size = "16px";
          };
          background = {
            color = stylix.withHashtag "base00";
          };
          border = {
            color = stylix.withHashtag "base0A";
            width = "2px";
            transition = "1.0s ease";
            radius = "5px";
          };
        };
      };
      programs.firefox = withSystem pkgs.stdenv.hostPlatform.system (
        {
          system,
          ...
        }:
        let
          firefox-addons = localFlake.inputs.firefox-addons.packages.${system};
        in
        {
          enable = true;
          profiles.${cfg.profile} = import ./${cfg.profile}-profile.nix { inherit firefox-addons pkgs; };
          package = pkgs.firefox;
        }
      );

      xdg.mimeApps.defaultApplications = {
        "text/html" = [ "firefox.desktop" ];
        "text/xml" = [ "firefox.desktop" ];
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
      };
    }
    // optionalAttrs stylix.hasStylix {
      stylix.targets.firefox.enable = true;
      stylix.targets.firefox.profileNames = [
        cfg.profile
      ];
    }
  );
}
