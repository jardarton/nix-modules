{ lib
, buildNpmPackage
, fetchFromGitHub
, bun
, nodejs
, git
, gh
,
}:

buildNpmPackage rec {
  pname = "stack";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "kitlangton";
    repo = "stack";
    rev = "7c4227689ed91ee63c5770c3f9943a0253a35a35";
    hash = "sha256-kgkmSE03/6dFh1w1QqaW78ObKSwaDv9THZ+mrzbzc4k=";
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
