{ pkgs, ... }:
{
  packages = {
    # pkg-caelestia-cli = pkgs.callPackage ./my-caelestia { inherit inputs; };
    cclip = pkgs.callPackage ./cclip { };
    stack = pkgs.callPackage ./stack { };
    gondolin = pkgs.callPackage ./gondolin { };
  };
}
