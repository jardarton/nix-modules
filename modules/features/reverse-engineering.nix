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
    let
      spimdisasm = pkgs.callPackage ./reverse-engineering/spimdisasm.pkg.nix { };
    in
    {
      packages = {
        hbcdump = pkgs.callPackage ./reverse-engineering/hbcdump.pkg.nix { };
        inherit spimdisasm;
        splat64 = pkgs.callPackage ./reverse-engineering/splat64.pkg.nix { inherit spimdisasm; };
      };
    };
}
