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
  version = "3.3.1";

  src = fetchgit {
    url = "https://github.com/heather7283/cclip.git";
    rev = "4286de1c8407ccba51060764e82c6b425b4ca3dd";
    branchName = "main";
    leaveDotGit = false;
    sha256 = "sha256-rjDCYag0aG9mZuwzWNS5z/CzeEtpdjc9iMypKqIZK60=";

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
