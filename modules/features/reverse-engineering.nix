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
  reusableModules.home.reverse-engineering =
    {
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ ./reverse-engineering/home.nix ];

      modules.home.reverse-engineering.hbcdumpPackage =
        lib.mkDefault
          moduleFlake.packages.${pkgs.stdenv.hostPlatform.system}.hbcdump;
    };

  flake.homeModules.reverse-engineering = config.reusableModules.home.reverse-engineering;

  perSystem =
    {
      pkgs,
      system,
      ...
    }:
    {
      packages.hbcdump =
        if inputs ? nix-modules then
          moduleFlake.packages.${system}.hbcdump
        else
          pkgs.callPackage ./reverse-engineering/hbcdump.pkg.nix { };
    };
}
