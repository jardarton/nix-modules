{ localFlake, ... }:
{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.home.bun;
  bunfig = (pkgs.formats.toml { }).generate "bunfig.toml" {
    smol = false;
    telemetry = false;
    install = {
      # Only install package versions published at least 3 days ago
      minimumReleaseAge = 259200; # seconds

      # Exclude trusted packages from the age gate
      minimumReleaseAgeExcludes = [ ];
      ignoreScripts = true;
    };
  };
in
{

  options.modules.home.bun = {
    enable = mkOption {
      type = types.bool;
      default = true;
      example = true;
      description = "enable bun";
    };
  };

  config = mkIf cfg.enable {
    programs.bun.enable = true;
    home.file.".bunfig.toml".source = bunfig;
  };
}
