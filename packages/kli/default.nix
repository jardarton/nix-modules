{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "kli";
  version = "0-unstable-2026-06-15";

  src = fetchFromGitHub {
    owner = "bjarneo";
    repo = "kli";
    rev = "1582dee8b2a9e224c353214d32c918c23d8fb84b";
    hash = "sha256-pgcV0TxRg2brJXvuTUbiKzegYU0StV08kIyGf7VOeP8=";
  };

  vendorHash = "sha256-0gLwvJSEMgCw23YG8rMzoI7ubo0I5nvguex2HBJE1dU=";

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  meta = {
    description = "Terminal UI for Kubernetes";
    homepage = "https://github.com/bjarneo/kli";
    license = lib.licenses.unfree;
    mainProgram = "kli";
    platforms = lib.platforms.unix;
  };
}
