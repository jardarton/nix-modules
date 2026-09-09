{ rustPlatform, src }:
rustPlatform.buildRustPackage {
  pname = "herdr-plugin-navigator";
  version = "0.3.6";
  inherit src;
  cargoLock.lockFile = src + "/Cargo.lock";

  postInstall = ''
    cp herdr-plugin.toml "$out/"
    mkdir -p "$out/target/release"
    ln -s ../../bin/herdr-navigator "$out/target/release/herdr-navigator"
  '';

  passthru.manifestFile = src + "/herdr-plugin.toml";
  meta.mainProgram = "herdr-navigator";
}
