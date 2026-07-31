{
  config,
  inputs,
  self,
  ...
}:
let
  moduleFlake = inputs.nix-modules or self;
in
{
  reusableModules.home.herdr =
    {
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ ./herdr/home.nix ];

      modules.home.herdr = {
        package =
          lib.mkDefault
            moduleFlake.inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default;
        jjWorkspacePluginPackage = lib.mkDefault (
          pkgs.callPackage ./herdr/jj-workspace-plugin.pkg.nix {
            src = moduleFlake.inputs.herdr-plugin-jj-workspace;
          }
        );
      };
    };

  flake.homeModules.herdr = config.reusableModules.home.herdr;
}
