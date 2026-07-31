{
  lib,
  pkgs,
  ...
}:
{
  packages = {
    stack = pkgs.callPackage ./stack { };
    firecrawl-cli = pkgs.callPackage ./firecrawl-cli { };
    hbcdump = pkgs.callPackage ./hbcdump { };
    kli = pkgs.callPackage ./kli { };
    ntn = pkgs.callPackage ./ntn { };
    playwright-cli = pkgs.callPackage ./playwright-cli { };
  }
  // lib.optionalAttrs pkgs.stdenv.isLinux {
    cclip = pkgs.callPackage ./cclip { };
  };
}
