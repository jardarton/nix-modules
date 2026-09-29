{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_24,
}:

buildNpmPackage rec {
  pname = "playwright-cli";
  version = "0.1.22";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "playwright-cli";
    tag = "v${version}";
    hash = "sha256-80xzHvf7BHGvoKvMdkGeNUsUrpZrpw5eryuQM8NKT/E=";
  };

  nodejs = nodejs_24;
  npmDepsHash = "sha256-mGD7a/v1cx/xPGZo8nN3WA40mYGgF/KzMKiGbvUeX4E=";

  dontNpmBuild = true;

  meta = {
    description = "Playwright CLI";
    homepage = "https://github.com/microsoft/playwright-cli";
    license = lib.licenses.asl20;
    mainProgram = "playwright-cli";
    platforms = lib.platforms.unix;
  };
}
