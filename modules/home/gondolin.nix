{ localFlake, withSystem, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.home.gondolin;
in
{
  options.modules.home.gondolin = {
    enable = mkEnableOption "Gondolin sandbox CLI";

    package = mkOption {
      type = types.package;
      default = withSystem pkgs.stdenv.hostPlatform.system ({ config, ... }: config.packages.gondolin);
      defaultText = literalExpression "localFlake.packages.${pkgs.stdenv.hostPlatform.system}.gondolin";
      description = "Gondolin package to install.";
    };

    enableQemu = mkOption {
      type = types.bool;
      default = pkgs.stdenv.isLinux;
      defaultText = literalExpression "pkgs.stdenv.isLinux";
      example = false;
      description = "Install QEMU alongside Gondolin for the default qemu backend on Linux.";
    };
  };

  config = mkIf cfg.enable {
    warnings = optional pkgs.stdenv.isDarwin ''
      modules.home.gondolin: QEMU is not installed by this Home Manager module on macOS.
      Install it separately, for example with Homebrew (`brew install qemu`) or a nix-darwin Homebrew module.
    '';

    home.packages = [ cfg.package ] ++ optional (cfg.enableQemu && pkgs.stdenv.isLinux) pkgs.qemu;
  };
}
