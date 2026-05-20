{ localFlake, ... }:
{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.home.catsvim;

  neovimInput = localFlake.inputs.nixCats;
  wrapperModules = neovimInput.inputs."nix-wrapper-modules";
  baseModule = modules.importApply "${neovimInput}/module.nix" neovimInput.inputs;

  # Grab stylix override
  stylix16 = pkgs.lib.filterAttrs (
    k: v: builtins.match "base0[0-9A-F]" k != null
  ) config.lib.stylix.colors.withHashtag;

  commonAliases = [
    "catsvim"
    "neovim-nixCats"
    "nvim-nixCats"
    "neovimCats"
    "nvimCats"
    "nx"
  ];

  mkCatsvimPackage =
    profile: overrides:
    (wrapperModules.lib.evalModules {
      modules = [
        baseModule
        profile
        overrides
      ];
      specialArgs = { inherit pkgs; };
    }).config.wrap
      { inherit pkgs; };

  themeInfo = themeName: {
    settings.theme.name = mkForce themeName;
    info.opts.theme.name = mkForce themeName;
    info.opts.theme.base16 = mkIf (cfg.theme == "stylix") {
      enable = mkForce true;
      table = mkForce stylix16;
    };
  };

  catsvimPackage = mkCatsvimPackage (neovimInput + "/nix/profiles/full.nix") (
    { ... }:
    mkMerge [
      (themeInfo cfg.theme)
      {
        settings.aliases = mkForce commonAliases;
      }
    ]
  );

  catsviPackage = mkCatsvimPackage (neovimInput + "/nix/profiles/minimal.nix") (
    { ... }:
    mkMerge [
      (themeInfo "gruvbox")
      {
        settings.aliases = mkForce (commonAliases ++ [ "catsvi" ]);
      }
    ]
  );
in
{
  options.modules.home.catsvim = {
    enable = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = "enable catsvim";
    };
    catsvi = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = "enable catsvi";
    };
    theme = mkOption {
      type = types.str;
      default = "stylix";
      example = "gruvbox";
    };
  };

  config = mkIf (cfg.enable || cfg.catsvi) {
    home.packages = [
      (if cfg.enable then catsvimPackage else catsviPackage)
    ];

    home.sessionVariables = {
      CATSVIM = mkDefault (if cfg.enable then "catsvim" else "catsvi");
    };
    home.shellAliases = {
      n = "$CATSVIM";
    };
  };
}
