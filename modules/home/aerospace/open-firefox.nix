{ pkgs }:
pkgs.writeShellScriptBin "open-firefox" ''
  open -a firefox
''
