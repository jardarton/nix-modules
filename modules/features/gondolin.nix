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
  reusableModules.home.gondolin =
    {
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ ./gondolin/home.nix ];

      modules.home.gondolin.package =
        lib.mkDefault
          moduleFlake.packages.${pkgs.stdenv.hostPlatform.system}.gondolin;
    };

  flake.homeModules.gondolin = config.reusableModules.home.gondolin;

  perSystem =
    {
      pkgs,
      system,
      ...
    }:
    {
      packages.gondolin =
        if inputs ? nix-modules then
          moduleFlake.packages.${system}.gondolin
        else
          pkgs.callPackage ./gondolin/package.pkg.nix { };
    };
}
