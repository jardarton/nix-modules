{ lib, pkgs, ... }:
{
  packages = {
    stack = pkgs.callPackage ./stack { };
    gondolin = pkgs.callPackage ./gondolin { };
    kli = pkgs.callPackage ./kli { };
    playwright-cli = pkgs.callPackage ./playwright-cli { };
  }
  // lib.optionalAttrs pkgs.stdenv.isLinux {
    cclip = pkgs.callPackage ./cclip { };
  };
}
