{ pkgs, ... }:
{
  packages = {
    # pkg-caelestia-cli = pkgs.callPackage ./my-caelestia { inherit inputs; };
    cclip = pkgs.callPackage ./cclip { };
    stack = pkgs.callPackage ./stack { };
    gondolin = pkgs.callPackage ./gondolin { };
    kli = pkgs.callPackage ./kli { };
    playwright-cli = pkgs.callPackage ./playwright-cli { };
  };
}
