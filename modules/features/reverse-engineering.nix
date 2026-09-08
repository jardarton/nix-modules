{
  moduleWithSystem,
  ...
}:
{
  flake.modules.homeManager.reverse-engineering = moduleWithSystem (
    { config, ... }:
    { lib, ... }:
    {
      imports = [ ./reverse-engineering/home.nix ];

      modules.home.reverse-engineering = {
        enable = lib.mkDefault true;
        hbcdumpPackage = lib.mkDefault config.packages.hbcdump;
        mitmproxyPackage = lib.mkDefault config.packages.mitmproxy;
        angrPackage = lib.mkDefault config.packages.angr;
      };
    }
  );

  perSystem =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      packages.hbcdump = pkgs.callPackage ./reverse-engineering/hbcdump.pkg.nix { };
      packages.mitmproxy = pkgs.callPackage ./reverse-engineering/mitmproxy.pkg.nix { };
      packages.angr = pkgs.callPackage ./reverse-engineering/angr.pkg.nix { };

      checks = lib.optionalAttrs (pkgs.stdenv.hostPlatform.system == "x86_64-linux") {
        angr-smoke =
          pkgs.runCommand "angr-smoke"
            {
              nativeBuildInputs = [ (pkgs.python3.withPackages (_: [ config.packages.angr ])) ];
            }
            ''
              python ${./reverse-engineering/angr-smoke.py}
              touch "$out"
            '';
      };
    };
}
