_:
{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
let
  cfg = config.modules.home.aerospace;
  stylix = import ../lib/stylix.nix { inherit config options; };
in
{

  options.modules.home.aerospace = {
    enable = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = "enable aerospace";
    };
  };

  config = mkIf cfg.enable {
    services.jankyborders = {
      enable = true;
      settings = {
        style = "round";
        order = "above";
        width = 4.0;
        active_color = stylix.withHashtag "base08";
        inactive_color = stylix.withHashtag "base00";
      };
    };

    home.packages = [
      pkgs.aerospace
      (import ./open-firefox.nix { inherit pkgs; })
    ];

    home.file.".config/aerospace/aerospace.toml" = {
      source = ./aerospace.toml;
    };
  };
}
