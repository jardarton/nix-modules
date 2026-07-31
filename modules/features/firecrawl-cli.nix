{
  perSystem =
    { pkgs, ... }:
    {
      packages.firecrawl-cli = pkgs.callPackage ./firecrawl-cli/package.pkg.nix { };
    };
}
