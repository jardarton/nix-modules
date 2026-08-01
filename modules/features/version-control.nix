{
  config,
  moduleWithSystem,
  ...
}:
let
  moduleFlake = config.nixModules.sourceFlake;
in
{
  flake.modules.homeManager = {
    git = moduleWithSystem (
      { config, ... }:
      { lib, ... }:
      {
        imports = [ ./version-control/git.nix ];

        modules.home.git.hunkPackage = lib.mkDefault config.packages.hunk;
      }
    );

    jujutsu = moduleWithSystem (
      { config, ... }:
      { lib, pkgs, ... }:
      {
        imports = [ ./version-control/jujutsu.nix ];

        modules.home.jujutsu = {
          enable = lib.mkDefault true;
          hunkPackage = lib.mkDefault config.packages.hunk;
          jjStarship.package =
            lib.mkDefault
              moduleFlake.inputs.jj-starship.packages.${pkgs.stdenv.hostPlatform.system}.default;
        };
      }
    );
  };

  perSystem =
    { pkgs, system, ... }:
    {
      packages.hunk =
        (pkgs.callPackage "${moduleFlake.inputs.hunk}/nix/package.nix" {
          bun2nix = moduleFlake.inputs.hunk.inputs.bun2nix.packages.${system}.default;
        }).overrideAttrs
          (old: {
            meta = (old.meta or { }) // {
              mainProgram = "hunk";
            };
          });
    };
}
