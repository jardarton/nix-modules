{
  config,
  inputs,
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
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = lib.getAttrFromPath optionPath config;
      mangoPackage = moduleFlake.packages.${pkgs.stdenv.hostPlatform.system}.mango;
    in
    {
      imports = [
        externalModule
        implementation
      ];

      config = lib.mkIf cfg.enable (
        lib.setAttrByPath (optionPath ++ [ "package" ]) (lib.mkDefault mangoPackage)
      );
    };
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
      inputs',
      lib,
      pkgs,
      system,
      ...
    }:
    {
      packages = lib.optionalAttrs pkgs.stdenv.isLinux {
        mango =
          if inputs ? nix-modules then
            moduleFlake.packages.${system}.mango
          else
            inputs'.mango.packages.mango.overrideAttrs (old: {
              buildInputs = old.buildInputs ++ [ pkgs.libdrm ];
              NIX_CFLAGS_COMPILE = "-I${pkgs.libdrm.dev}/include/libdrm";
            });
      };
    };
}
