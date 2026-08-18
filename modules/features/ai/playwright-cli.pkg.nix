{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_24,
}:

buildNpmPackage rec {
  pname = "playwright-cli";
  version = "0.1.18";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "playwright-cli";
    rev = "ca196c297169a494ee5517584883eada60dc8d0e";
    hash = "sha256-E/AzDJhD12PWSaA3iRY+hloPsSWnAw18gTa/ItVhr3E=";
  };

  nodejs = nodejs_24;
  npmDepsHash = "sha256-3kqiQvGtZfsmLHVWeCSM1yOYb+ws2x1vMPC1OuvrKAI=";

  dontNpmBuild = true;

  meta = {
    description = "Playwright CLI";
    homepage = "https://github.com/microsoft/playwright-cli";
    license = lib.licenses.asl20;
    mainProgram = "playwright-cli";
    platforms = lib.platforms.unix;
  };
}
