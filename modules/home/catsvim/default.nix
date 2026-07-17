{ localFlake, ... }:
{
  pkgs,
  config,
  lib,
  options,
  ...
}:
with lib;
let
  cfg = config.modules.home.catsvim;
  stylix = import ../lib/stylix.nix { inherit config options; };

  neovimInput = localFlake.inputs.nixCats;
  wrapperModules = neovimInput.inputs."nix-wrapper-modules";
  baseModule = modules.importApply "${neovimInput}/module.nix" neovimInput.inputs;

  # Grab stylix override
  stylix16 = builtins.listToAttrs (
    map
      (name: {
        inherit name;
        value = stylix.withHashtag name;
      })
      [
        "base00"
        "base01"
        "base02"
        "base03"
        "base04"
        "base05"
        "base06"
        "base07"
        "base08"
        "base09"
        "base0A"
        "base0B"
        "base0C"
        "base0D"
        "base0E"
        "base0F"
      ]
  );

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
