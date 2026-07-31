{
  perSystem =
    { pkgs, ... }:
    {
      packages.stack = pkgs.callPackage ./stack/package.pkg.nix { };
    };
}
