{
  perSystem =
    { pkgs, ... }:
    {
      packages.ntn = pkgs.callPackage ./ntn/package.pkg.nix { };
    };
}
