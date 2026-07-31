{ lib, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages = lib.optionalAttrs pkgs.stdenv.isLinux {
        cclip = pkgs.callPackage ./cclip/package.pkg.nix { };
      };
    };
}
