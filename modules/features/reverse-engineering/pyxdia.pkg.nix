{
  lib,
  buildPythonPackage,
  fetchPypi,
  fetchurl,
  setuptools,
  unzip,
}:
let
  xdia = fetchurl {
    url = "https://github.com/mborgerson/xdia/releases/download/v0.1.0/xdia.zip";
    hash = "sha256-rtKcSZoL8OUo2l1B/WJYACIu+DFEqahfTvbjeNsmq8s=";
  };
  xdialdr = fetchurl {
    url = "https://github.com/mborgerson/xdia/releases/download/v0.1.0/xdialdr.tar.xz";
    hash = "sha256-rXL7uVl+TJYYhKrqzkF7YK0nZ+rwSnGKsTyxAN/mlYQ=";
  };
in
buildPythonPackage {
  pname = "pyxdia";
  version = "0.1.0";
  pyproject = true;
  src = fetchPypi {
    pname = "pyxdia";
    version = "0.1.0";
    hash = "sha256:af95d1ce70407e7a0f72d02ba77d366c0dfb0ed58fb336f8725ac8f3493b7e68";
  };
  build-system = [ setuptools ];
  nativeBuildInputs = [ unzip ];
  # Upstream's build downloads these helpers. Supply the same assets offline.
  postPatch = ''
    mkdir -p pyxdia/bin
    unzip ${xdia} -d pyxdia/bin
    tar -xf ${xdialdr} -C pyxdia/bin
    chmod +x pyxdia/bin/xdialdr
  '';
  pythonImportsCheck = [ "pyxdia" ];
  meta = {
    description = "Python PDB reader using xdia and Microsoft's redistributable DIA library";
    homepage = "https://github.com/mborgerson/pyxdia";
    license = lib.licenses.unfreeRedistributable;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    # Other platforms need an additional Blink emulator, not yet packaged here.
    platforms = [ "x86_64-linux" ];
  };
}
