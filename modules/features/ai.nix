{
  config,
  inputs,
  self,
  ...
}:
let
  moduleFlake = inputs.nix-modules or self;
in
{
  reusableModules.home.ai =
    {
      lib,
      pkgs,
      ...
    }:
    let
      system = pkgs.stdenv.hostPlatform.system;
      llmPackages = moduleFlake.inputs.llm-agents.packages.${system};
    in
    {
      imports = [ ./ai/home.nix ];

      modules.home.ai.defaultPackages = lib.mapAttrs (_: lib.mkDefault) {
        inherit (llmPackages) agent-browser copilot-cli opencode;
        inherit (pkgs) codex;
        claude = llmPackages.claude-code;
        playwright-cli = moduleFlake.packages.${system}.playwright-cli;
      };
    };

  flake.homeModules.ai = config.reusableModules.home.ai;

  perSystem =
    {
      pkgs,
      system,
      ...
    }:
    {
      packages.playwright-cli =
        if inputs ? nix-modules then
          moduleFlake.packages.${system}.playwright-cli
        else
          pkgs.callPackage ./ai/playwright-cli.pkg.nix { };
    };
}
