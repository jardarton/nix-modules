{
  inputs,
  ...
}:
{
  imports = [ inputs.pre-commit-hooks.flakeModule ];

  perSystem =
    {
      config,
      system,
      pkgs,
      ...
    }:
    {
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

      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    };
}
