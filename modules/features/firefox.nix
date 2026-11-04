{
  config,
  lib,
  ...
}:
let
  moduleFlake = config.nixModules.sourceFlake;
  textfox = moduleFlake.inputs.textfox;
  textfoxModule = import "${textfox.outPath}/nix/modules/home-manager.nix" {
    self.packages = lib.mapAttrs (_system: _packages: {
      default = textfox.outPath;
    }) textfox.packages;
  };

  # Upstream sources shared by both browsers. The key lets the module system
  # deduplicate it, so an accidental import of both exports reaches the clearer
  # error from `modules.home.firefox.variant`.
  sources = {
    key = "nix-modules#firefox-sources";
    imports = [
      (
        { lib, pkgs, ... }:
        {
          modules.home.firefox = {
            addons =
              lib.mkDefault
                moduleFlake.inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system};
            arkenfox = lib.mkDefault "${moduleFlake.inputs.arkenfox}/user.js";
          };
        }
      )
    ];
  };
in
{
  flake.modules.homeManager = {
    # The full browser: arkenfox hardening, textfox, Vimium and a set of
    # productivity add-ons.
    firefox.imports = [
      sources
      textfoxModule
      ./firefox/main.nix
    ];

    # A private, minimal browser for people who just want to browse: arkenfox
    # hardening relaxed so nothing surprises them, and uBlock Origin.
    firefox-minimal.imports = [
      sources
      ./firefox/minimal.nix
    ];
  };
}
