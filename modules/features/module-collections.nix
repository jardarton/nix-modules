{
  config,
  inputs,
  lib,
  self,
  ...
}:
{
  options.nixModules.sourceFlake = lib.mkOption {
    type = lib.types.raw;
    default = inputs.nix-modules or self;
    defaultText = lib.literalExpression "inputs.nix-modules or self";
    description = ''
      The nix-modules flake that owns the inputs used by reusable features.
      The exported flake module sets this independently of its consumer-side
      input name; the default preserves compatibility with direct path imports.
    '';
  };

  # Preserve the established outputs while storing modules in flake-parts'
  # class-aware module collection.
  config.flake = {
    homeModules = config.flake.modules.homeManager;
    nixosModules = config.flake.modules.nixos;
  };
}
