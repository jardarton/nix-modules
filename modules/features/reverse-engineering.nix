{
  config,
  moduleWithSystem,
  ...
}:
{
  reusableModules.home.reverse-engineering = moduleWithSystem (
    { config, ... }:
    { lib, ... }:
    {
      imports = [ ./reverse-engineering/home.nix ];

      modules.home.reverse-engineering.hbcdumpPackage = lib.mkDefault config.packages.hbcdump;
    }
  );

  flake.homeModules.reverse-engineering = config.reusableModules.home.reverse-engineering;

  perSystem =
    { pkgs, ... }:
    {
      packages.hbcdump = pkgs.callPackage ./reverse-engineering/hbcdump.pkg.nix { };
    };
}
