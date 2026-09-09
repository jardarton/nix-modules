{
  autoPatchelfHook,
  fetchurl,
  lib,
  src,
  stdenv,
}:
let
  version = "0.3.0";
  plannotatorTuiVersion = "0.7.0";
  targets = {
    x86_64-linux = {
      name = "x86_64-unknown-linux-gnu";
      hash = "sha256-j4FK/WPGMQDf0Vx+TC1ciSTnSUPoF4gMOciAwvicmUQ=";
    };
    aarch64-linux = {
      name = "aarch64-unknown-linux-gnu";
      hash = "sha256-GUgIcAHloC6Hn9oVhmjLVZ5ARTREageGEN55mwtTBRQ=";
    };
    aarch64-darwin = {
      name = "aarch64-apple-darwin";
      hash = "sha256-tSA4uqJko3INV8mg5Wc9uG1eB7mNY5cz+WIb6IuPFSg=";
    };
  };
  target =
    targets.${stdenv.hostPlatform.system}
      or (throw "herdr-annotate: unsupported system ${stdenv.hostPlatform.system}");
  plannotatorTui = fetchurl {
    url = "https://github.com/plannotator/plannotator-tui/releases/download/v${plannotatorTuiVersion}/plannotator-tui-${target.name}";
    inherit (target) hash;
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
  };
}
