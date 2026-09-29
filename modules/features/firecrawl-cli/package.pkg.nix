{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  makeWrapper,
  nodejs_24,
  pnpm_10,
  pnpmConfigHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "firecrawl-cli";
  version = "1.24.6";

  src = fetchFromGitHub {
    owner = "firecrawl";
    repo = "cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5CULHaMxRq1HCZo37z8CGfkBQ5oQG/6fF77zQM8xv+E=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    fetcherVersion = 3;
    hash = "sha256-fQqxe/4W+/N29QcJdeKmVfKQmgNy0+87DmUSVSCgrUc=";
  };

  nativeBuildInputs = [
    makeWrapper
    nodejs_24
    pnpm_10
    pnpmConfigHook
  ];

  buildPhase = ''
    runHook preBuild
    pnpm build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/firecrawl-cli $out/bin
    cp -r dist node_modules package.json $out/lib/firecrawl-cli/
    makeWrapper ${nodejs_24}/bin/node $out/bin/firecrawl \
      --add-flags $out/lib/firecrawl-cli/dist/index.js

    runHook postInstall
  '';

  meta = {
    description = "Command-line interface for Firecrawl";
    homepage = "https://github.com/firecrawl/cli";
    license = lib.licenses.isc;
    mainProgram = "firecrawl";
    platforms = lib.platforms.unix;
  };
})
