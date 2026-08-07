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
      # Only install package versions published at least 7 days ago
      minimumReleaseAge = 604800; # seconds

      # Exclude trusted packages from the age gate
      inherit (cfg) minimumReleaseAgeExcludes;
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

    minimumReleaseAgeExcludes = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "@scope/package" ];
      description = ''
        Packages that the `minimumReleaseAge` gate does not apply to.

        Each entry must be an exact package name. Bun does not accept glob
        patterns here, so `@scope/*` matches nothing. The exclusion also does
        not cascade: a transitive dependency that is itself too new stays
        blocked unless it is listed as well.
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.bun.enable = true;
    home.file.".bunfig.toml".source = bunfig;
  };
}
