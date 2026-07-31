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
  reusableModules.home = {
    git =
      {
        lib,
        pkgs,
        ...
      }:
      {
        imports = [ ./version-control/git.nix ];

        modules.home.git.hunkPackage =
          lib.mkDefault
            moduleFlake.inputs.hunk.packages.${pkgs.stdenv.hostPlatform.system}.default;
      };

    jujutsu =
      {
        lib,
        pkgs,
        ...
      }:
      {
        imports = [ ./version-control/jujutsu.nix ];

        modules.home.jujutsu = {
          hunkPackage =
            lib.mkDefault
              moduleFlake.inputs.hunk.packages.${pkgs.stdenv.hostPlatform.system}.default;
          jjStarship.package =
            lib.mkDefault
              moduleFlake.inputs.jj-starship.packages.${pkgs.stdenv.hostPlatform.system}.default;
        };
      };
  };

  flake.homeModules = {
    git = config.reusableModules.home.git;
    jujutsu = config.reusableModules.home.jujutsu;
  };
}
