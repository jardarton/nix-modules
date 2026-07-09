{ lib
, buildNpmPackage
, fetchFromGitHub
, nodejs_24
,
}:

buildNpmPackage rec {
  pname = "gondolin";
  version = "0.12.0-unstable-2026-07-06";

  src = fetchFromGitHub {
    owner = "earendil-works";
    repo = "gondolin";
    rev = "29fa74d802112f29c720990aced26165e0d57d84";
    hash = "sha256-pjXCSIIbnwxbsAR+heX6j56Ygtt2yDlv6wQ7Y+rtAGk=";
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
    platforms = lib.platforms.unix;
  };
}
