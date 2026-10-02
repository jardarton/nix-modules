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
  version = "0.160.0";

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
      codex = "sha256-MGhlQX1O56kneFhSkQpSf0Hh4Vmt05CsWuOsy2fUShM=";
      codex-code-mode-host = "sha256-rGzWKI8OOfRqM+uhz9N3EWUfFPM9vHPWobgutF4DjKw=";
    };
    "aarch64-unknown-linux-musl" = {
      codex = "sha256-iDYgE5kl9nfloSyVuoeh1/QhOI67eXscEKukKgTt6dc=";
      codex-code-mode-host = "sha256-lAZv3xP/7NL1h3bsXLj8MEAoOmQuPW/yXF2CBIxBA44=";
    };
    "x86_64-apple-darwin" = {
      codex = "sha256-pQwQYG5OgbjdL3trq2NVlaq8dzyEzyBxdz+68GeCX78=";
      codex-code-mode-host = "sha256-sCTro2bsLjtnNJcqAN+O2be/FOZwV5vFuhgZRhLZ9EE=";
    };
    "aarch64-apple-darwin" = {
      codex = "sha256-B8PHyjdqj3kRFTQvUxON2jfpfPopuBJdBlLZN4SJS10=";
      codex-code-mode-host = "sha256-3HD7x26dyuWuPVQkgIyOfC314NtKyCfd1PvjOQFarXU=";
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
