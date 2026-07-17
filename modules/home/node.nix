{ ... }:
{ lib
, pkgs
, config
, ...
}:

let
  cfg = config.modules.home.node;
in
{
  options.modules.home.node = with lib; {
    enable = mkOption {
      type = types.bool;
      default = true;
      example = true;
      description = "enable node";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.npm = {
      enable = true;
      package = pkgs.nodejs_24;
      settings = {
        color = true;
        prefix = "\${HOME}/.npm";
        min-release-age = 7;
        minimum-release-age = 10080;
        ignore-scripts = true;
        allow-git = "none";
      };
    };
  };
}
