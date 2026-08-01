{
  config,
  inputs,
  moduleWithSystem,
  self,
  ...
}:
let
  moduleFlake = inputs.nix-modules or self;

  mkMangoModule =
    {
      externalModule,
      implementation,
      optionPath,
    }:
    moduleWithSystem (
      { config, ... }:
      let
        perSystemConfig = config;
      in
      { config, lib, ... }:
      let
        cfg = lib.getAttrFromPath optionPath config;
      in
      {
        imports = [
          externalModule
          implementation
        ];

        config = lib.mkIf cfg.enable (
          lib.setAttrByPath (optionPath ++ [ "package" ]) (lib.mkDefault perSystemConfig.packages.mango)
        );
      }
    );
in
{
  reusableModules = {
    home.mango = mkMangoModule {
      externalModule = moduleFlake.inputs.mango.hmModules.mango;
      implementation = ./mango/home.nix;
      optionPath = [
        "modules"
        "home"
        "mango"
      ];
    };

    nixos.mango = mkMangoModule {
      externalModule = moduleFlake.inputs.mango.nixosModules.mango;
      implementation = ./mango/nixos.nix;
      optionPath = [
        "modules"
        "nixos"
        "mango"
      ];
    };
  };

  flake = {
    homeModules.mango = config.reusableModules.home.mango;
    nixosModules.mango = config.reusableModules.nixos.mango;
  };

  perSystem =
    {
      lib,
      pkgs,
      system,
      ...
    }:
    {
      packages = lib.optionalAttrs pkgs.stdenv.isLinux {
        mango =
          (pkgs.callPackage "${moduleFlake.inputs.mango}/nix" {
            scenefx = moduleFlake.inputs.mango.inputs.scenefx.packages.${system}.default;
          }).overrideAttrs
            (old: {
              buildInputs = old.buildInputs ++ [ pkgs.libdrm ];
              NIX_CFLAGS_COMPILE = "-I${pkgs.libdrm.dev}/include/libdrm";
            });
      };
    };
}
