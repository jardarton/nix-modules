{
  cmake,
  fetchFromGitHub,
  icu,
  lib,
  ninja,
  python3,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "hbcdump";
  version = "250829098.0.16";

  src = fetchFromGitHub {
    owner = "facebook";
    repo = "hermes";
    tag = "hermes-v${finalAttrs.version}";
    hash = "sha256-GZxn7KHKpSvjdx0M8/TPdxOwby8VxlR5GAo+4+1Hzjs=";
  };

  buildInputs = [ icu ];

  nativeBuildInputs = [
    cmake
    ninja
    python3
  ];

  cmakeFlags = [
    (lib.cmakeBool "HERMES_BUILD_APPLE_FRAMEWORK" false)
    (lib.cmakeBool "HERMES_BUILD_SHARED_JSI" false)
    (lib.cmakeBool "HERMES_ENABLE_DEBUGGER" false)
    (lib.cmakeBool "HERMES_ENABLE_INTL" false)
    (lib.cmakeBool "HERMES_ENABLE_TEST_SUITE" false)
    (lib.cmakeBool "HERMES_ENABLE_TOOLS" true)
    (lib.cmakeBool "HERMES_ENABLE_UNICODE_REGEXP_PROPERTY_ESCAPES" false)
  ];

  buildPhase = ''
    runHook preBuild
    cmake --build . --target hbcdump
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 bin/hbcdump "$out/bin/hbcdump"
    runHook postInstall
  '';

  meta = {
    description = "Disassembler for Hermes bytecode files";
    homepage = "https://github.com/facebook/hermes";
    license = lib.licenses.mit;
    mainProgram = "hbcdump";
    platforms = lib.platforms.unix;
  };
})
