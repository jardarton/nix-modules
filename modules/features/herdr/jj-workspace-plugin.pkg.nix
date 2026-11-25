{
  lib,
  runCommand,
  rustPlatform,
  src,
}:
let
  rustPackage = rustPlatform.buildRustPackage {
    pname = "jj-workspace";
    version = "0.4.0";
    inherit src;
    cargoLock.lockFile = src + "/Cargo.lock";
    meta.mainProgram = "jj-workspace";
  };
in
runCommand "herdr-plugin-nathanflurry-jj-workspace"
  {
    passthru.manifestFile = src + "/herdr-plugin.toml";
    meta = {
      description = "Create jj workspaces with Codex on the left and a terminal on the right";
      homepage = "https://github.com/NathanFlurry/herdr-plugin-jj-workspace";
      license = lib.licenses.mit;
      platforms = lib.platforms.unix;
    };
  }
  ''
    mkdir -p "$out/target/release"
    cp ${src}/herdr-plugin.toml "$out/herdr-plugin.toml"
    cp ${lib.getExe rustPackage} "$out/target/release/jj-workspace"
  ''
