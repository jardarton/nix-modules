{
  perSystem =
    { pkgs, ... }:
    {
      packages.hbcdump = pkgs.callPackage ./hbcdump/package.pkg.nix { };
    };
}
