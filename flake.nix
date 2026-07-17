{
  description = "Reusable NixOS and Home Manager modules";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.gnome-shell.url = "github:GNOME/gnome-shell/ef02db02bf0ff342734d525b5767814770d85b49";
    };
    nixCats = {
      url = "github:jardarton/neovim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    textfox.url = "github:adriankarlen/textfox";
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mango = {
      url = "github:DreamMaoMao/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fsel.url = "github:Mjoyufull/fsel";
    television.url = "github:alexpasmantier/television";
    llm-agents.url = "github:numtide/llm-agents.nix";
    hunk = {
      url = "github:modem-dev/hunk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    herdr = {
      url = "github:ogulcancelik/herdr";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    herdr-plugin-jj-workspace = {
      url = "github:NathanFlurry/herdr-plugin-jj-workspace";
      flake = false;
    };
    jj-starship = {
      url = "github:dmmulroy/jj-starship";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      imports = [
        inputs.flake-parts.flakeModules.flakeModules
        inputs.home-manager.flakeModules.home-manager
        inputs.pre-commit-hooks.flakeModule
        ./modules
      ];

      flake.flakeModule = ./modules;

      perSystem =
        {
          config,
          system,
          pkgs,
          ...
        }:
        {
          imports = [ ./packages ];
          formatter = pkgs.nixfmt-tree;
          pre-commit.settings.hooks = {
            nixfmt.enable = true;
            statix = {
              enable = true;
              settings.config = toString (
                pkgs.writeText "statix.toml" ''
                  disabled = ["repeated_keys"]
                  ignore = [".direnv"]
                ''
              );
            };
            deadnix.enable = true;
          };
          devShells.default = pkgs.mkShell {
            inherit (config.pre-commit) shellHook;
            packages = config.pre-commit.settings.enabledPackages;
          };
          checks = pkgs.lib.mapAttrs' (
            name: module:
            let
              inherit
                (
                  (inputs.home-manager.lib.homeManagerConfiguration {
                    inherit pkgs;
                    modules = [
                      module
                      {
                        home = {
                          username = "module-test";
                          homeDirectory = "/home/module-test";
                          stateVersion = "26.05";
                        };
                      }
                    ];
                  })
                )
                activationPackage
                ;
              evaluated = builtins.addErrorContext "while evaluating homeModules.${name}: " activationPackage.drvPath;
            in
            pkgs.lib.nameValuePair "home-module-${name}" (
              builtins.seq evaluated (pkgs.runCommand "check-home-module-${name}" { } "touch $out")
            )
          ) self.homeModules;
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        };
    };
}
