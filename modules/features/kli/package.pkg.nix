{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "kli";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "bjarneo";
    repo = "kli";
    rev = "v${version}";
    hash = "sha256-pdwfNP9RnD4LQKYJ315wrhiRdQN9i/KZ/13jMNlKzvw=";
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
