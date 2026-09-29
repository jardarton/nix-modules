{
  autoPatchelfHook,
  fetchurl,
  lib,
  src,
  stdenv,
}:
let
  version = "0.8.0";
  herdrAnnotateVersion = "0.2.0";
  plannotatorTuiVersion = "0.9.4";
  targets = {
    x86_64-linux = {
      name = "x86_64-unknown-linux-gnu";
      annotateHash = "sha256-o+9OcnhLuoz3nlgtYCHKNPDWAPFw2jCVvMYKh7G8uUI=";
      tuiHash = "sha256-1U3GA8lfcQZ3vBPr5rJLLm6xDOdhV3r4qVoFAChit00=";
    };
    aarch64-linux = {
      name = "aarch64-unknown-linux-gnu";
      annotateHash = "sha256-xNOA7VpwzXtDZCgsPXApCkgal5NQYrvlxnJXmRxpH28=";
      tuiHash = "sha256-45B3qsLh537XmNJZD4Rc+ZjkVvoqIS/nyuLiX+v2III=";
    };
    aarch64-darwin = {
      name = "aarch64-apple-darwin";
      annotateHash = "sha256-WpxT03fNh+ZN4BueQ8hJBFP2q4GhExHTQKS/8HDqQwg=";
      tuiHash = "sha256-qdpJ3WpE00lP7Q6DZsoymW7N9A4CcfztQQzsPIg5F10=";
    };
  };
  target =
    targets.${stdenv.hostPlatform.system}
      or (throw "herdr-annotate: unsupported system ${stdenv.hostPlatform.system}");
  plannotatorTui = fetchurl {
    url = "https://github.com/plannotator/plannotator-tui/releases/download/v${plannotatorTuiVersion}/plannotator-tui-${target.name}";
    hash = target.tuiHash;
  };
  herdrAnnotate = fetchurl {
    url = "https://github.com/plannotator/herdr-annotate/releases/download/rust-lite-v${herdrAnnotateVersion}/herdr-annotate-${target.name}";
    hash = target.annotateHash;
  };
in
stdenv.mkDerivation {
  pname = "herdr-plugin-annotate";
  inherit version src;

  dontBuild = true;
  nativeBuildInputs = lib.optional stdenv.hostPlatform.isLinux autoPatchelfHook;
  buildInputs = lib.optional stdenv.hostPlatform.isLinux stdenv.cc.cc.lib;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -R . "$out/"
    chmod -R u+w "$out"
    install -Dm755 ${herdrAnnotate} "$out/bin/herdr-annotate.exe"
    printf %s ${lib.escapeShellArg herdrAnnotateVersion} > "$out/bin/herdr-annotate.version"
    install -Dm755 ${plannotatorTui} "$out/bin/plannotator-tui.exe"
    printf %s ${lib.escapeShellArg plannotatorTuiVersion} > "$out/bin/plannotator-tui.version"

    runHook postInstall
  '';

  passthru.manifestFile = src + "/herdr-plugin.toml";

  meta = {
    description = "Annotate terminal selections and documents inside Herdr";
    homepage = "https://github.com/plannotator/herdr-annotate";
    license = lib.licenses.mit;
    platforms = builtins.attrNames targets;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
