{
  # Upstream publishes DuckStation only as an x86_64/ARM Linux AppImage; the
  # package wraps the x86_64 build.
  perSystem =
    { lib, pkgs, ... }:
    {
      packages = lib.optionalAttrs (pkgs.stdenv.hostPlatform.system == "x86_64-linux") {
        duckstation = pkgs.callPackage ./duckstation/package.pkg.nix { };
      };
    };
}
