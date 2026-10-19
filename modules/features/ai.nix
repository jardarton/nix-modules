{
  config,
  moduleWithSystem,
  ...
}:
let
  moduleFlake = config.nixModules.sourceFlake;
in
{
  flake.modules.homeManager.ai = moduleWithSystem (
    { config, ... }:
    { lib, pkgs, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
      llmPackages = moduleFlake.inputs.llm-agents.packages.${system};
      # llm-agents installs 2.x as opencode2 so it can coexist with 1.x; keep
      # the usual command name since this replaces 1.x.
      opencode = pkgs.symlinkJoin {
        name = "opencode-${llmPackages.opencode2.version}";
        paths = [ llmPackages.opencode2 ];
        postBuild = "ln -s opencode2 $out/bin/opencode";
        inherit (llmPackages.opencode2) meta;
      };
    in
    {
      imports = [ ./ai/home.nix ];

      modules.home.ai.defaultPackages = lib.mapAttrs (_: lib.mkDefault) {
        inherit (llmPackages) agent-browser copilot-cli;
        inherit opencode;
        claude = llmPackages.claude-code;
        codex = config.packages.codex;
        playwright-cli = config.packages.playwright-cli;
      };
    }
  );

  perSystem =
    { pkgs, ... }:
    {
      packages = {
        codex = pkgs.callPackage ./ai/codex.pkg.nix { };
        playwright-cli = pkgs.callPackage ./ai/playwright-cli.pkg.nix { };
      };
    };
}
