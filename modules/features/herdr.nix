{
  config,
  ...
}:
let
  moduleFlake = config.nixModules.sourceFlake;
in
{
  flake.modules.homeManager.herdr =
    {
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ ./herdr/home.nix ];

      modules.home.herdr = {
        enable = lib.mkDefault true;
        package =
          lib.mkDefault
            moduleFlake.inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default;
        jjWorkspacePluginPackage = lib.mkDefault (
          pkgs.callPackage ./herdr/jj-workspace-plugin.pkg.nix {
            src = moduleFlake.inputs.herdr-plugin-jj-workspace;
          }
        );
        jjWorkspacePluginManifestFile = lib.mkDefault "${moduleFlake.inputs.herdr-plugin-jj-workspace}/herdr-plugin.toml";
        worktrunkPluginPackage = lib.mkDefault (
          pkgs.callPackage ./herdr/worktrunk-plugin.pkg.nix {
            src = moduleFlake.inputs.herdr-worktrunk;
          }
        );
        worktrunkPluginManifestFile = lib.mkDefault "${moduleFlake.inputs.herdr-worktrunk}/herdr-plugin.toml";
      };
    };
}
