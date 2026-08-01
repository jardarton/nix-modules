{
  config,
  lib,
  ...
}:
let
  moduleFlake = config.nixModules.sourceFlake;
  textfox = moduleFlake.inputs.textfox;
  textfoxModule = import "${textfox.outPath}/nix/modules/home-manager.nix" {
    self.packages = lib.mapAttrs (_system: _packages: {
      default = textfox.outPath;
    }) textfox.packages;
  };
in
{
  flake.modules.homeManager.firefox =
    {
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        ./firefox/home.nix
        textfoxModule
      ];

      modules.home.firefox.addons =
        lib.mkDefault
          moduleFlake.inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system};
    };
}
