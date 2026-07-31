{
  lib,
  stdenv,
  fetchurl,
}:

let
  platform =
    {
      aarch64-darwin = "darwin-arm64";
      x86_64-darwin = "darwin-x64";
      aarch64-linux = "linux-arm64";
      x86_64-linux = "linux-x64";
    }
    .${stdenv.hostPlatform.system} or (throw "ntn: unsupported platform ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation (finalAttrs: {
  pname = "ntn";
  version = "0.21.6";

  src = fetchurl {
    url = "https://registry.npmjs.org/ntn/-/ntn-${finalAttrs.version}.tgz";
    hash = "sha256-ykA1FbQBO+6q5F8OquLSFFp9a4ETvuNxccmmxclt5MQ=";
  };

  sourceRoot = "package";

  installPhase = ''
    runHook preInstall

    install -Dm755 dist/ntn-${platform}/ntn $out/bin/ntn

    runHook postInstall
  '';

  meta = {
    description = "Notion CLI";
    homepage = "https://ntn.dev";
    license = lib.licenses.mit;
    mainProgram = "ntn";
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
