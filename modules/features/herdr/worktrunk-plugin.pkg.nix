{
  runCommand,
  src,
}:
runCommand "herdr-plugin-worktrunk"
  {
    passthru.manifestFile = src + "/herdr-plugin.toml";
  }
  ''
    cp -R ${src}/. "$out"
    chmod +x "$out"/*.sh
  ''
