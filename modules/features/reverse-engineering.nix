{
  moduleWithSystem,
  ...
}:
{
  flake.modules.homeManager.reverse-engineering = moduleWithSystem (
    { config, ... }:
    { lib, ... }:
    {
      imports = [ ./reverse-engineering/home.nix ];

      modules.home.reverse-engineering = {
        enable = lib.mkDefault true;
        hbcdumpPackage = lib.mkDefault config.packages.hbcdump;
      };
    }
  );

  perSystem =
    { pkgs, ... }:
    {
      packages.hbcdump = pkgs.callPackage ./reverse-engineering/hbcdump.pkg.nix { };
    };
}
