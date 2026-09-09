{
  rustPlatform,
  git,
  src,
}:
rustPlatform.buildRustPackage {
  pname = "herdr-plugin-nvim";
  version = "1.0.0";
  inherit src;
  cargoLock.lockFile = src + "/Cargo.lock";
  nativeCheckInputs = [ git ];
  # The picker integration test indexes tracked files; flake sources omit .git.
  preCheck = ''
    git init
    git add .
  '';

  postInstall = ''
    cp herdr-plugin.toml "$out/"
    cp -R herdr lua plugin doc "$out/"
  '';

  passthru.manifestFile = src + "/herdr-plugin.toml";
  meta.mainProgram = "herdr-nvim";
}
