{
  config,
  moduleWithSystem,
  ...
}:
{
  reusableModules.home.gondolin = moduleWithSystem (
    { config, ... }:
    { lib, ... }:
    {
      imports = [ ./gondolin/home.nix ];

      modules.home.gondolin.package = lib.mkDefault config.packages.gondolin;
    }
  );

  flake.homeModules.gondolin = config.reusableModules.home.gondolin;

  perSystem =
    { pkgs, ... }:
    {
      packages.gondolin = pkgs.callPackage ./gondolin/package.pkg.nix { };
    };
}
