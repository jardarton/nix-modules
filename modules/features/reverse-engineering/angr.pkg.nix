{
  python3,
  fetchFromGitHub,
  fetchPypi,
  rustPlatform,
  cargo,
  rustc,
  cmake,
  ninja,
}:
let
  version = "9.2.193";
  binaries = fetchFromGitHub {
    owner = "angr";
    repo = "binaries";
    tag = "v${version}";
    hash = "sha256-CuKEWn+7almL7d3ZEiUxHMEoF9E7RxZ6zMtdkBAKeOQ=";
  };
  # Keep the mutually version-pinned angr stack in its own Python scope.
  # nixpkgs currently mixes 9.2.154 and 9.2.193 and omits the Rust build.
  python = python3.override {
    packageOverrides = final: prev: {
      # angr subclasses the pre-3.0 parser/lexer API.
      pycparser = prev.pycparser.overridePythonAttrs {
        version = "2.23";
        src = fetchPypi {
          pname = "pycparser";
          version = "2.23";
          hash = "sha256:78816d4f24add8f10a06d6f05b4d424ad9e96cfebf68a4ddc99c65c0720d00c2";
        };
      };
      archinfo = prev.archinfo.overridePythonAttrs {
        inherit version;
        src = fetchFromGitHub {
          owner = "angr";
          repo = "archinfo";
          tag = "v${version}";
          hash = "sha256-n7tbm+BHeCtKwsqcj56LB4YyQZRAp6Ehj7m91QFQrFM=";
        };
      };
      pyvex = prev.pyvex.overridePythonAttrs {
        inherit version;
        build-system = [
          final.scikit-build-core
          final.cffi
        ];
        nativeBuildInputs = [
          cmake
          ninja
        ];
        dontUseCmakeConfigure = true;
        preBuild = "";
        setupPyBuildFlags = [ ];
        src = fetchPypi {
          pname = "pyvex";
          inherit version;
          hash = "sha256:f097bf9aac73cc7e9d1fa1480375b11300bfa9f6b7740a953d3a036ea1b7a944";
        };
      };
      arpy = prev.arpy.overridePythonAttrs {
        version = "1.1.1";
        # This historical sdist has no tests; keep the import check and exercise
        # archive loading through CLE's test suite instead.
        doCheck = false;
        src = fetchPypi {
          pname = "arpy";
          version = "1.1.1";
          hash = "sha256:3ec36309d2234648ef8dcd2118fe7d81c30195087e0353473546583f3434e776";
        };
      };
      pyxdia = final.callPackage ./pyxdia.pkg.nix { };
      cle = prev.cle.overridePythonAttrs (old: {
        inherit version;
        src = fetchFromGitHub {
          owner = "angr";
          repo = "cle";
          tag = "v${version}";
          hash = "sha256-YCmRNmUFtC5vl/zP0fyT63ODkz3Wo1ChwSY29hx7gwY=";
        };
        dependencies = (old.dependencies or [ ]) ++ [
          final.arpy
          final.minidump
          final.pyxbe
          final.pyxdia
          final.uefi-firmware
        ];
        nativeCheckInputs = (old.nativeCheckInputs or [ ]) ++ [ final.pypcode ];
        preCheck = ''
          export HOME=$TMPDIR
          cp -r ${binaries} "$HOME/binaries"
        '';
      });
      angr = prev.angr.overridePythonAttrs (old: {
        build-system = (old.build-system or [ ]) ++ [ final.setuptools-rust ];
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
          rustPlatform.cargoSetupHook
          cargo
          rustc
        ];
        cargoDeps = rustPlatform.fetchCargoVendor {
          inherit (old) src;
          hash = "sha256-HnvNJW7Q3bWr2VxtM+Ux0gyDC5P5QlHjZwooyOkGaow=";
        };
        dependencies = (old.dependencies or [ ]) ++ [
          final.lmdb
          final.msgspec
          final.pypcode
          final.typing-extensions
        ];
      });
    };
  };
in
python.pkgs.angr
