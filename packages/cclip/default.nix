{ lib
, stdenv
, sqlite
, wayland
, wayland-scanner
, fetchgit
, meson
, ninja
, git
, xxhash
, cmake
, pkg-config
, ...
}:

stdenv.mkDerivation rec {
  pname = "cclip";
  version = "3.3.1-unstable-2026-03-17";

  src = fetchgit {
    url = "https://github.com/heather7283/cclip.git";
    rev = "83b0d80519acd5868bf7ed0114cb312c89828e74";
    branchName = "main";
    leaveDotGit = false;
    sha256 = "sha256-EFfLqMfP3MgEKK0NYEETHTMhWpe64MMXnNNPVBaeTQw=";

  };

  nativeBuildInputs = [
    meson
    cmake
    git
    ninja # Meson often uses Ninja as its backend
    pkg-config
  ];

  buildInputs = [
    sqlite
    wayland
    wayland-scanner
    xxhash
  ];

  # buildPhase = ''
  #   meson setup --buildtype=release build
  #   meson compile -C build
  # '';

  meta = with lib; {
    description = "cclip clipboard history";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
