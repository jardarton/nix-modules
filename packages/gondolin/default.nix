{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_24,
}:

buildNpmPackage rec {
  pname = "gondolin";
  version = "0.12.0-unstable-2026-05-23";

  src = fetchFromGitHub {
    owner = "earendil-works";
    repo = "gondolin";
    rev = "e0b339e74bdbd47bc21b943330a128d81cd1070a";
    hash = "sha256-3/N8KzYFs7F9n5jenDpXrroSsOFNv8FextxMcRU89IE=";
  };

  sourceRoot = "${src.name}/host";

  nodejs = nodejs_24;
  npmDepsHash = "sha256-cV7p7NAL6JaICqUWFQFYfKc5JpzfIOPdJYbBgem9RRQ=";

  postPatch = ''
    sed -i '/^  "optionalDependencies": {/,/^  },$/d' package.json
  '';

  npmFlags = [ "--omit=optional" ];
  npmBuildScript = "build";

  meta = {
    description = "Alpine Linux sandbox for running untrusted code with controlled filesystem and network access";
    homepage = "https://github.com/earendil-works/gondolin";
    license = lib.licenses.asl20;
    mainProgram = "gondolin";
    platforms = lib.platforms.linux;
  };
}
