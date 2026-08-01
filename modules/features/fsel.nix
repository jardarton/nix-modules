{
  config,
  moduleWithSystem,
  ...
}:
let
  moduleFlake = config.nixModules.sourceFlake;
in
{
  flake.modules.homeManager.fsel = moduleWithSystem (
    { config, ... }:
    { lib, pkgs, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
    in
    {
      imports = [ ./fsel/home.nix ];

      config = lib.mkMerge [
        { modules.home.fsel.enable = lib.mkDefault pkgs.stdenv.isLinux; }
        (lib.mkIf pkgs.stdenv.isLinux {
          modules.home.fsel = {
            package = lib.mkDefault moduleFlake.inputs.fsel.packages.${system}.default;
            cclipPackage = lib.mkDefault config.packages.cclip;
          };
        })
      ];
    }
  );

  perSystem =
    { lib, pkgs, ... }:
    {
      packages = lib.optionalAttrs pkgs.stdenv.isLinux {
        cclip = pkgs.callPackage ./fsel/cclip.pkg.nix { };
      };
    };
}
