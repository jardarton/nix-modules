{ lib
, buildNpmPackage
, fetchFromGitHub
, nodejs_24
,
}:

buildNpmPackage rec {
  pname = "playwright-cli";
  version = "0.1.15";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "playwright-cli";
    rev = "74d9bf144a96770b6295ceedecb07a2fd7e86775";
    hash = "sha256-M0NZ7h1kSIsxktMWe5n75LDc+MHZvSq6b+iRx6opakU=";
  };

  nodejs = nodejs_24;
  npmDepsHash = "sha256-ZrO8yIqMYMQUlsQraejVgKRZ7klC5/8UsV3/H1EqYtA=";

  dontNpmBuild = true;

  meta = {
    description = "Playwright CLI";
    homepage = "https://github.com/microsoft/playwright-cli";
    license = lib.licenses.asl20;
    mainProgram = "playwright-cli";
    platforms = lib.platforms.unix;
  };
}
