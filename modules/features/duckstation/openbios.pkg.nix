# OpenBIOS, the MIT-licensed PlayStation 1 BIOS from PCSX-Redux, built from
# its nugget source tree. DuckStation recognises it as a BIOS image, so games
# boot without a retail BIOS dump. Known incompatible games are listed in
# openbios/COMPATIBILITY.md upstream.
#
# nugget needs a bare-metal little-endian MIPS toolchain (mipsel-none-elf).
# nixpkgs has no pkgsCross entry for it, so the cross package set is created
# here. The toolchain is not in the public binary cache; the first build
# compiles binutils and GCC.
#
# OpenBIOS is freestanding, so the build uses GCC without a target C library,
# as upstream's toolchain does. newlib's MIPS support code does not build for
# MIPS I. That GCC has no C++, so the image embeds the C shell instead of the
# psyqo-based default.
{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  path,
  stdenv,
}:
let
  mipsel = import path {
    localSystem = stdenv.buildPlatform;
    crossSystem = {
      config = "mipsel-none-elf";
      # The PlayStation's R3000A is a MIPS I CPU. Without this, nixpkgs uses
      # its mipsel Linux default of MIPS32r2 for the compiler wrapper's
      # -march and GCC's built-in default, which clashes with nugget's
      # -march=mips1.
      gcc.arch = "mips1";
    };
  };
  toolchain = mipsel.buildPackages;
in
stdenvNoCC.mkDerivation {
  pname = "openbios";
  version = "0-unstable-2026-11-04";

  src = fetchFromGitHub {
    owner = "pcsx-redux";
    repo = "nugget";
    rev = "80f296b4fe1c29bd391d35d33071453a0d94f569";
    hash = "sha256-8VI4Yr1+wMew1lqsBTPqNbeHNxuO4Egsqt8I87dPsx4=";
  };

  # Freestanding firmware; the Makefile sets its own code generation flags.
  hardeningDisable = [ "all" ];

  nativeBuildInputs = [
    toolchain.gccWithoutTargetLibc
  ];

  buildPhase = ''
    runHook preBuild
    make -C openbios -j$NIX_BUILD_CORES BUILD=Release PREFIX=mipsel-none-elf OPENBIOS_SHELL=shell
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm644 openbios/openbios.bin $out/share/openbios/openbios.bin
    runHook postInstall
  '';

  meta = {
    description = "Open-source PlayStation 1 BIOS from PCSX-Redux";
    homepage = "https://github.com/pcsx-redux/nugget/tree/main/openbios";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
