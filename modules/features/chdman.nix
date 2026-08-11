{
  perSystem =
    { pkgs, ... }:
    {
      packages.chdman = pkgs.callPackage ./chdman/package.pkg.nix { };
    };
}
