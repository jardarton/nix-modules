{ mitmproxy }:
mitmproxy.overridePythonAttrs (old: {
  # Backport upstream's dependency bounds without disabling runtime checks or
  # tests. Remove when nixpkgs ships these bounds in its Mitmproxy package.
  # https://github.com/mitmproxy/mitmproxy/blob/2ac5b089d953585c66026a53f678270e094e48e5/pyproject.toml
  postPatch = (old.postPatch or "") + ''
    substituteInPlace pyproject.toml \
      --replace-fail "cryptography>=42.0,<=48.1" "cryptography>=42.0,<=50.0.0" \
      --replace-fail "tornado>=6.5.0,<=6.5.5" "tornado>=6.5.0,<=6.5.8"
  '';
})
