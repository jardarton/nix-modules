{ localFlake, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) literalExpression mkEnableOption mkIf mkOption optionals types;
  cfg = config.modules.home.reverse-engineering;

  corePackages = with pkgs; [
    binutils
    file
    hexyl
    jq
    ripgrep
    upx
    yara
  ];

  nativePackages = with pkgs; [
    gdb
    lldb
    patchelf
    radare2
  ] ++ optionals pkgs.stdenv.isLinux (with pkgs; [
    ltrace
    strace
  ]);

  androidPackages = with pkgs; [
    android-tools
    apktool
    jadx
  ];

  firmwarePackages = with pkgs; [
    binwalk
    dtc
    squashfsTools
    ubootTools
  ];
in
{
  options.modules.home.reverse-engineering = {
    enable = mkEnableOption "reverse-engineering tools";

    native.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Install native binary analysis and debugging tools.";
    };

    android.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Install Android command-line analysis tools.";
    };

    firmware.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Install firmware inspection and extraction tools.";
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      example = literalExpression "[ pkgs.ghidra ]";
      description = "Additional reverse-engineering packages to install.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = corePackages
      ++ optionals cfg.native.enable nativePackages
      ++ optionals cfg.android.enable androidPackages
      ++ optionals cfg.firmware.enable firmwarePackages
      ++ cfg.extraPackages;
  };
}
