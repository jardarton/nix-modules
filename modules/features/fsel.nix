{
  config,
  inputs,
  moduleWithSystem,
  self,
  ...
}:
let
  moduleFlake = inputs.nix-modules or self;
in
{
  reusableModules.home.fsel = moduleWithSystem (
    { config, ... }:
    { lib, pkgs, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
    in
    {
      imports = [ ./fsel/home.nix ];

      modules.home.fsel = {
        package = lib.mkDefault moduleFlake.inputs.fsel.packages.${system}.default;
        cclipPackage = lib.mkDefault config.packages.cclip;
      };
    }
  );

  flake.homeModules.fsel = config.reusableModules.home.fsel;

  perSystem =
    { lib, pkgs, ... }:
    {
      packages = lib.optionalAttrs pkgs.stdenv.isLinux {
        cclip = pkgs.callPackage ./fsel/cclip.pkg.nix { };
      };
    };
}
