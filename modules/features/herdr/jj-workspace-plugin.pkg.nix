{
  lib,
  runCommand,
  rustPlatform,
  src,
}:
let
  rustPackage = rustPlatform.buildRustPackage {
    pname = "jj-workspace";
    version = "0.1.0";
    inherit src;
    cargoLock.lockFile = src + "/Cargo.lock";
    meta.mainProgram = "jj-workspace";
  };
in
runCommand "herdr-plugin-nathanflurry-jj-workspace" { } ''
  mkdir -p "$out/target/release"
  cp ${src}/herdr-plugin.toml "$out/herdr-plugin.toml"
  cp ${lib.getExe rustPackage} "$out/target/release/jj-workspace"
''
