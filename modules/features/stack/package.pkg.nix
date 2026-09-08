{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  bun,
  nodejs,
  git,
  gh,
}:

buildNpmPackage rec {
  pname = "stack";
  version = "0.4.6";

  src = fetchFromGitHub {
    owner = "kitlangton";
    repo = "stack";
    rev = "cc918c499481993692c9859a4b61a91e4912a19c";
    hash = "sha256-v3KassEhOG9BkHxOOWsWBkYcdvy0Cw891pbda/TWzIE=";
  };

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-RxR1wRkoXCvONqpATH/v5L+1+MhLxmxmYL0AgWTcTGA=";

  npmFlags = [ "--legacy-peer-deps" ];

  npmBuildScript = "build";

  nativeBuildInputs = [
    bun
    nodejs
  ];

  runtimeInputs = [
    git
    gh
  ];

  meta = {
    description = "Squash-safe stacked PR repair CLI";
    homepage = "https://github.com/kitlangton/stack";
    license = lib.licenses.mit;
    mainProgram = "stack";
    platforms = lib.platforms.unix;
  };
}
