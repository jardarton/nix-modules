{
  runCommand,
  src,
}:
runCommand "herdr-plugin-worktrunk" { } ''
  cp -R ${src}/. "$out"
  chmod +x "$out"/*.sh
''
