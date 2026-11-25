{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  installShellFiles,
  bubblewrap,
  ripgrep,
  curl,
  jq,
  nix,
  python3,
  writeShellApplication,
  installShellCompletions ? stdenv.buildPlatform.canExecute stdenv.hostPlatform,
}:

let
  version = "0.172.0";

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
      codex = "sha256-ojQqj39o8Ii+MGIMz+nLhBYsk6a1YXeFWWHNo+1r45I=";
      codex-code-mode-host = "sha256-ILCkvPMyQVpZl5FMlD0Er2w2J68MN5/b9lQAVQ41K7Q=";
    };
    "aarch64-unknown-linux-musl" = {
      codex = "sha256-C5lSbBhaRCX+lqIhT7e2pqf3wUcYg7evvr6X4V6D554=";
      codex-code-mode-host = "sha256-tmN+uqNT6jqTTUDjdRKJqaOe2Bz5b+P6Ov6hHjhA3Gg=";
    };
    "x86_64-apple-darwin" = {
      codex = "sha256-EKCXKhU1IGMF57DOKwlt20JTVCtKwVmSZbLQwImNJ4o=";
      codex-code-mode-host = "sha256-j5N/5fwDLCpcvkAdRLvb4W9kLvihduI7MZ92+Cst31M=";
    };
    "aarch64-apple-darwin" = {
      codex = "sha256-vRIfir1rKLP8R22gSjSOJag+ie2hnTkQf2j46WYFMJI=";
      codex-code-mode-host = "sha256-6rJPiObiDIgdjBG39w7iIP0ZqUxYbsa86tEqIOAstuQ=";
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

  passthru.updateScript = lib.getExe (writeShellApplication {
    name = "update-codex";
    runtimeInputs = [
      curl
      jq
      nix
      python3
    ];
    text = ''
      set -euo pipefail
      pkg_file="modules/features/ai/codex.pkg.nix"
      if [ ! -f "$pkg_file" ]; then
        echo "Run from the repository root (missing $pkg_file)" >&2
        exit 1
      fi

      latest_tag=$(curl -fsSL https://api.github.com/repos/openai/codex/releases/latest | jq -r '.tag_name')
      new_version="''${latest_tag#rust-v}"
      current_version="${version}"

      if [ "$new_version" = "$current_version" ]; then
        echo "codex is already at $current_version"
        exit 0
      fi

      echo "Updating codex: $current_version -> $new_version"
      declare -A new_hashes
      for target in x86_64-unknown-linux-musl aarch64-unknown-linux-musl x86_64-apple-darwin aarch64-apple-darwin; do
        for asset in codex codex-code-mode-host; do
          url="https://github.com/openai/codex/releases/download/rust-v''${new_version}/''${asset}-''${target}.tar.gz"
          raw_hash=$(nix-prefetch-url --type sha256 "$url")
          new_hashes["''${target}:''${asset}"]=$(nix hash convert --hash-algo sha256 --to sri "$raw_hash")
        done
      done

      NEW_VERSION="$new_version" \
      HASH_X64_LINUX_CODEX="''${new_hashes[x86_64-unknown-linux-musl:codex]}" \
      HASH_X64_LINUX_HOST="''${new_hashes[x86_64-unknown-linux-musl:codex-code-mode-host]}" \
      HASH_ARM_LINUX_CODEX="''${new_hashes[aarch64-unknown-linux-musl:codex]}" \
      HASH_ARM_LINUX_HOST="''${new_hashes[aarch64-unknown-linux-musl:codex-code-mode-host]}" \
      HASH_X64_DARWIN_CODEX="''${new_hashes[x86_64-apple-darwin:codex]}" \
      HASH_X64_DARWIN_HOST="''${new_hashes[x86_64-apple-darwin:codex-code-mode-host]}" \
      HASH_ARM_DARWIN_CODEX="''${new_hashes[aarch64-apple-darwin:codex]}" \
      HASH_ARM_DARWIN_HOST="''${new_hashes[aarch64-apple-darwin:codex-code-mode-host]}" \
      python3 - "$pkg_file" <<'PY'
      import os, re, sys

      path = sys.argv[1]
      text = open(path).read()
      text = re.sub(r'(version\s*=\s*")[^"]+(";)', rf'\g<1>{os.environ["NEW_VERSION"]}\g<2>', text, count=1)

      mapping = {
          "x86_64-unknown-linux-musl": (os.environ["HASH_X64_LINUX_CODEX"], os.environ["HASH_X64_LINUX_HOST"]),
          "aarch64-unknown-linux-musl": (os.environ["HASH_ARM_LINUX_CODEX"], os.environ["HASH_ARM_LINUX_HOST"]),
          "x86_64-apple-darwin": (os.environ["HASH_X64_DARWIN_CODEX"], os.environ["HASH_X64_DARWIN_HOST"]),
          "aarch64-apple-darwin": (os.environ["HASH_ARM_DARWIN_CODEX"], os.environ["HASH_ARM_DARWIN_HOST"]),
      }
      for target, (h_codex, h_host) in mapping.items():
          pattern = rf'("{re.escape(target)}"\s*=\s*\{{\s*codex\s*=\s*")[^"]+(";\s*codex-code-mode-host\s*=\s*")[^"]+(";)'
          text, n = re.subn(pattern, rf'\g<1>{h_codex}\g<2>{h_host}\g<3>', text, count=1)
          assert n == 1, f"Failed to update hashes for {target}"

      open(path, "w").write(text)
      PY
    '';
  });

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
