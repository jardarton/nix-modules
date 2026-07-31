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
  reusableModules.home.devops =
    {
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ ./devops/home.nix ];

      modules.home.devops.kliPackage =
        lib.mkDefault
          moduleFlake.packages.${pkgs.stdenv.hostPlatform.system}.kli;
    };

  flake.homeModules.devops = config.reusableModules.home.devops;
}
