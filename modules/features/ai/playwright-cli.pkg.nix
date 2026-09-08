{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_24,
}:

buildNpmPackage rec {
  pname = "playwright-cli";
  version = "0.1.19";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "playwright-cli";
    rev = "655530f6d0dc71a0d6bf46ae165877d3c7311099";
    hash = "sha256-Z9+WgdgqtSYTKfRgJ51UAnXqlPPhhtU/yzH+qYblVeg=";
  };

  nodejs = nodejs_24;
  npmDepsHash = "sha256-aY3i+sc2p8iQAEpfs+j/ifeBVmMpDDmwctEqOIDmCqI=";

  dontNpmBuild = true;

  meta = {
    description = "Playwright CLI";
    homepage = "https://github.com/microsoft/playwright-cli";
    license = lib.licenses.asl20;
    mainProgram = "playwright-cli";
    platforms = lib.platforms.unix;
  };
}
