{
  lib,
  runCommand,
  src,
}:
runCommand "herdr-plugin-worktrunk"
  {
    passthru.manifestFile = src + "/herdr-plugin.toml";
    meta = {
      description = "Switch, create, remove, or merge git worktrees via Worktrunk in Herdr";
      homepage = "https://github.com/devashish2203/herdr-worktrunk";
      license = lib.licenses.mit;
      platforms = lib.platforms.unix;
    };
  }
  ''
    cp -R ${src}/. "$out"
    chmod +x "$out"/*.sh
  ''
