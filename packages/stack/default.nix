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
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "kitlangton";
    repo = "stack";
    rev = "ac714a3d841dba95b51b2307fc74f359ef0a7036";
    hash = "sha256-IZW1/7iKjNvpbGvLBd2PGDaJXpreoZeemUsNswChZeE=";
  };

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-UqOC1OU8CjWjcdvfESPzbJRG+56uxbsRRNNVa58OVLE=";

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
