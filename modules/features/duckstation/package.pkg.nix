# DuckStation from upstream's AppImage. nixpkgs removed its source build at
# upstream's request (2026-03-14) and points users to the AppImage instead.
# Upstream tags each build `v0.1-<n>`; bump `version` and `hash` together.
{
  lib,
  appimageTools,
  fetchurl,
}:
let
  pname = "duckstation";
  version = "0.1-12083";
  src = fetchurl {
    url = "https://github.com/stenzek/duckstation/releases/download/v${version}/DuckStation-x64.AppImage";
    hash = "sha256-xebwRfaiQggvyvqfAtVq2JXiM7lCcoeI0jKtDAx2XCQ=";
  };
  contents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  # Libraries the AppImage expects from the host but does not bundle.
  extraPkgs = pkgs: [ pkgs.libgpg-error ];

  extraInstallCommands = ''
    install -Dm644 ${contents}/org.duckstation.DuckStation.desktop \
      $out/share/applications/org.duckstation.DuckStation.desktop
    substituteInPlace $out/share/applications/org.duckstation.DuckStation.desktop \
      --replace-fail 'TryExec=duckstation-qt' 'TryExec=${pname}' \
      --replace-fail 'Exec=duckstation-qt' 'Exec=${pname}'
    install -Dm644 ${contents}/org.duckstation.DuckStation.png \
      $out/share/icons/hicolor/512x512/apps/org.duckstation.DuckStation.png
  '';

  meta = {
    description = "Fast PlayStation 1 emulator";
    homepage = "https://github.com/stenzek/duckstation";
    license = lib.licenses.cc-by-nc-nd-40;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
  };
}
