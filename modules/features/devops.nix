{
  moduleWithSystem,
  ...
}:
{
  flake.modules.homeManager.devops = moduleWithSystem (
    { config, ... }:
    { lib, ... }:
    {
      imports = [ ./devops/home.nix ];

      modules.home.devops.kliPackage = lib.mkDefault config.packages.kli;
    }
  );

  perSystem =
    { pkgs, ... }:
    {
      packages.kli = pkgs.callPackage ./kli/package.pkg.nix { };
    };
}
