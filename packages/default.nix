{
  inputs',
  lib,
  pkgs,
  ...
}:
{
  packages = {
    stack = pkgs.callPackage ./stack { };
    gondolin = pkgs.callPackage ./gondolin { };
    firecrawl-cli = pkgs.callPackage ./firecrawl-cli { };
    hbcdump = pkgs.callPackage ./hbcdump { };
    kli = pkgs.callPackage ./kli { };
    playwright-cli = pkgs.callPackage ./playwright-cli { };
  }
  // lib.optionalAttrs pkgs.stdenv.isLinux {
    cclip = pkgs.callPackage ./cclip { };
    mango = inputs'.mango.packages.mango.overrideAttrs (old: {
      buildInputs = old.buildInputs ++ [ pkgs.libdrm ];
      NIX_CFLAGS_COMPILE = "-I${pkgs.libdrm.dev}/include/libdrm";
    });
  };
}
