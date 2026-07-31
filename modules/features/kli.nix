{
  perSystem =
    { pkgs, ... }:
    {
      packages.kli = pkgs.callPackage ./kli/package.pkg.nix { };
    };
}
