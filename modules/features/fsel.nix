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
  reusableModules.home.fsel =
    {
      lib,
      pkgs,
      ...
    }:
    let
      system = pkgs.stdenv.hostPlatform.system;
    in
    {
      imports = [ ./fsel/home.nix ];

      modules.home.fsel = {
        package = lib.mkDefault moduleFlake.inputs.fsel.packages.${system}.default;
        cclipPackage = lib.mkDefault moduleFlake.packages.${system}.cclip;
      };
    };

  flake.homeModules.fsel = config.reusableModules.home.fsel;

  perSystem =
    {
      lib,
      pkgs,
      system,
      ...
    }:
    {
      packages = lib.optionalAttrs pkgs.stdenv.isLinux {
        cclip =
          if inputs ? nix-modules then
            moduleFlake.packages.${system}.cclip
          else
            pkgs.callPackage ./fsel/cclip.pkg.nix { };
      };
    };
}
