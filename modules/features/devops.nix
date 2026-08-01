{
  config,
  moduleWithSystem,
  ...
}:
{
  reusableModules.home.devops = moduleWithSystem (
    { config, ... }:
    { lib, ... }:
    {
      imports = [ ./devops/home.nix ];

      modules.home.devops.kliPackage = lib.mkDefault config.packages.kli;
    }
  );

  flake.homeModules.devops = config.reusableModules.home.devops;

  perSystem =
    { pkgs, ... }:
    {
      packages.kli = pkgs.callPackage ./kli/package.pkg.nix { };
    };
}
