{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  installShellFiles,
  bubblewrap,
  ripgrep,
  installShellCompletions ? stdenv.buildPlatform.canExecute stdenv.hostPlatform,
}:

let
  version = "0.167.0";

  # Prebuilt Rust binaries from the upstream GitHub release. The Linux assets
  # are statically linked against musl, so they need no ELF patching.
  targets = {
    "x86_64-linux" = "x86_64-unknown-linux-musl";
    "aarch64-linux" = "aarch64-unknown-linux-musl";
    "x86_64-darwin" = "x86_64-apple-darwin";
    "aarch64-darwin" = "aarch64-apple-darwin";
  };

  hashes = {
    "x86_64-unknown-linux-musl" = {
      codex = "sha256-nWSDYQbVs3TpDuRFTH683nynEGVYvX5Bo0ufJuvaJRo=";
      codex-code-mode-host = "sha256-tQdNXdZGQ7LAc5J+SUpYjv8xwfWifxLB4sRfmmzwfdQ=";
    };
    "aarch64-unknown-linux-musl" = {
      codex = "sha256-hDSJrLTUsQeXRcNrA8WWO4h7gxVa8gj9U1hOM+6OsoE=";
      codex-code-mode-host = "sha256-bpmUj6IMqBagHyIqVq+iYbMh4Ay+1hHXa7ksdl/RHsY=";
    };
    "x86_64-apple-darwin" = {
      codex = "sha256-2OtKhloLFzGc3hA0dSPlurCXjQFyWzn0pjn0CQXgEiE=";
      codex-code-mode-host = "sha256-YS0Nwscxb78F7pInlvTXQKKFt2pV1MeOG5RrpiG9zJE=";
    };
    "aarch64-apple-darwin" = {
      codex = "sha256-SyKiqXG+J5HD4x+RLz53qI69ZKZYEqconMumXdZCX+k=";
      codex-code-mode-host = "sha256-h2o+JjNI7w7a6uXPW8UqXBIRQc79FRV6sO7KMF8+tWM=";
    };
  };

  system = stdenv.hostPlatform.system;
  target =
    targets.${system}
      or (throw "codex: no upstream release binary for ${system}; supported systems: ${lib.concatStringsSep ", " (lib.attrNames targets)}");

  fetchAsset =
    name:
    fetchurl {
      url = "https://github.com/openai/codex/releases/download/rust-v${version}/${name}-${target}.tar.gz";
      hash = hashes.${target}.${name};
    };

  codexBinary = fetchAsset "codex";
  codeModeHost = fetchAsset "codex-code-mode-host";

  # Codex shells out to bubblewrap for its sandbox on Linux.
  runtimePath = lib.makeBinPath (lib.optional stdenv.hostPlatform.isLinux bubblewrap);
in
stdenvNoCC.mkDerivation {
  pname = "codex";
  inherit version;

  dontUnpack = true;
  dontPatchELF = true;
  dontStrip = true;

  nativeBuildInputs = [ makeWrapper ] ++ lib.optional installShellCompletions installShellFiles;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/libexec/package/{bin,codex-path,codex-resources}

    # Codex looks for the code-mode host next to the executable it runs, so both
    # binaries live in libexec and only the wrapper goes on PATH.
    tar -xzf ${codexBinary} -C $out/libexec/package/bin
    tar -xzf ${codeModeHost} -C $out/libexec/package/bin
    mv $out/libexec/package/bin/codex-${target} $out/libexec/package/bin/codex
    mv $out/libexec/package/bin/codex-code-mode-host-${target} $out/libexec/package/bin/codex-code-mode-host
    chmod +x $out/libexec/package/bin/codex $out/libexec/package/bin/codex-code-mode-host
    cp ${ripgrep}/bin/rg $out/libexec/package/codex-path/rg
    ${lib.optionalString stdenv.hostPlatform.isLinux "cp ${bubblewrap}/bin/bwrap $out/libexec/package/codex-resources/bwrap"}
    printf '%s\n' '{"version":"${version}","target":"${target}","entrypoint":"bin/codex"}' > $out/libexec/package/codex-package.json

    ln -s ../libexec/package/bin/codex-code-mode-host $out/bin/codex-code-mode-host

    # Inherited from sadjow/codex-cli-nix: a stable executable path is intended
    # to avoid macOS permission resets when Nix store paths change. This package
    # does not create ~/.local/bin/codex; consumers must provide that symlink or
    # set CODEX_EXECUTABLE_PATH to their own stable launcher path.
    makeWrapper $out/libexec/package/bin/codex $out/bin/codex \
      --set DISABLE_AUTOUPDATER 1 \
      --run 'export CODEX_EXECUTABLE_PATH="''${CODEX_EXECUTABLE_PATH:-$HOME/.local/bin/codex}"' \
      ${lib.optionalString stdenv.hostPlatform.isLinux ''--prefix PATH : "${runtimePath}"''}

    runHook postInstall
  '';

  postInstall = lib.optionalString installShellCompletions ''
    installShellCompletion --cmd codex \
      --bash <($out/bin/codex completion bash) \
      --fish <($out/bin/codex completion fish) \
      --zsh <($out/bin/codex completion zsh)
  '';

  meta = {
    description = "OpenAI Codex CLI, the coding agent that runs in your terminal";
    homepage = "https://github.com/openai/codex";
    changelog = "https://github.com/openai/codex/releases/tag/rust-v${version}";
    license = lib.licenses.asl20;
    mainProgram = "codex";
    platforms = lib.attrNames targets;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
