{ lib, ... }:
{
  options.reusableModules = {
    nixos = lib.mkOption {
      type = lib.types.attrsOf lib.types.deferredModule;
      default = { };
      description = "Reusable NixOS modules assembled by top-level feature modules.";
    };

    home = lib.mkOption {
      type = lib.types.attrsOf lib.types.deferredModule;
      default = { };
      description = "Reusable Home Manager modules assembled by top-level feature modules.";
    };
  };
}
