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
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "kitlangton";
    repo = "stack";
    rev = "1be576f03ef265d223f62e02b589c06d6edcf47e";
    hash = "sha256-auCYibRmSMndzruwHK+yfkAWJweKzTs5SA/kxLvp+Ps=";
  };

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-Z44jcaxWcgIn4f9jQMo72bNsPl1Cv2//aUYt2Q7VSCQ=";

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
