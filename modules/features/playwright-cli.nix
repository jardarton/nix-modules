{
  perSystem =
    { pkgs, ... }:
    {
      packages.playwright-cli = pkgs.callPackage ./playwright-cli/package.pkg.nix { };
    };
}
