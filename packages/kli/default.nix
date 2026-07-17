{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "kli";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "bjarneo";
    repo = "kli";
    rev = "f06c23134312d9371c98a4c8f4971d59bc9274ac";
    hash = "sha256-vXNOES9pVz6O6YX832Q+6zhctSvOgrZ/RoScppnLdYM=";
  };

  vendorHash = "sha256-x7O2/uKnIIFDr8WK0ej3FJiIGxN5Fq5Czqrv4OJ5A44=";

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
