{ lib
, buildGoModule
, fetchFromGitHub
,
}:

buildGoModule rec {
  pname = "kli";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "bjarneo";
    repo = "kli";
    rev = "bf1b6e41f079e5d77469107f7d1899f6269a4d13";
    hash = "sha256-8zBTxIdKlRDlFYvnjNZvqweSVcMvIQIgSxbPVB4IlBw=";
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
