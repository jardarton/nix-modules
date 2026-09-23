{
  config,
  moduleWithSystem,
  ...
}:
let
  moduleFlake = config.nixModules.sourceFlake;
in
{
  flake.modules.homeManager.herdr = moduleWithSystem (
    { config, ... }:
    { lib, pkgs, ... }:
    {
      imports = [ ./herdr/home.nix ];

      modules.home.herdr = {
        enable = lib.mkDefault true;
        package =
          lib.mkDefault
            moduleFlake.inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default;
        plugins.jjWorkspace.package = lib.mkDefault config.packages.herdr-plugin-jj-workspace;
        plugins.worktrunk.package = lib.mkDefault config.packages.herdr-plugin-worktrunk;
        plugins.nvim.package = lib.mkDefault config.packages.herdr-plugin-nvim;
        plugins.navigator.package = lib.mkDefault config.packages.herdr-plugin-navigator;
        plugins.annotate.package = lib.mkDefault config.packages.herdr-plugin-annotate;
      };
    }
  );

  perSystem =
    { pkgs, ... }:
    {
      packages = {
        herdr-plugin-annotate = pkgs.callPackage ./herdr/annotate-plugin.pkg.nix {
          src = moduleFlake.inputs.herdr-annotate;
        };
        herdr-plugin-navigator = pkgs.callPackage ./herdr/navigator-plugin.pkg.nix {
          src = moduleFlake.inputs.herdr-navigator;
        };
        herdr-plugin-nvim = pkgs.callPackage ./herdr/nvim-plugin.pkg.nix {
          src = moduleFlake.inputs.herdr-nvim;
        };
        herdr-plugin-jj-workspace = pkgs.callPackage ./herdr/jj-workspace-plugin.pkg.nix {
          src = moduleFlake.inputs.herdr-plugin-jj-workspace;
        };
        herdr-plugin-worktrunk = pkgs.callPackage ./herdr/worktrunk-plugin.pkg.nix {
          src = moduleFlake.inputs.herdr-worktrunk;
        };
      };
    };
}
