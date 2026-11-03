{
  rustPlatform,
  git,
  neovim,
  procps,
  util-linux,
  src,
}:
rustPlatform.buildRustPackage {
  pname = "herdr-plugin-nvim";
  version = "1.1.0";
  inherit src;
  cargoLock.lockFile = src + "/Cargo.lock";
  # The daemon tests drive real nvim daemons and inspect them with ps. They
  # kill process groups with `kill -- -<pgid>`, which procps's kill rejects, so
  # util-linux's kill must come first on PATH.
  nativeCheckInputs = [
    git
    neovim
    util-linux
    procps
  ];
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
