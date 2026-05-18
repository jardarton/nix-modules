{ localFlake, ... }:
{
  pkgs,
  config,
  inputs,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.home.catsvim;
  # Grab stylix override
  stylix16 = pkgs.lib.filterAttrs (
    k: v: builtins.match "base0[0-9A-F]" k != null
  ) config.lib.stylix.colors.withHashtag;
in
{

  imports = [
    localFlake.inputs.nixCats.homeModules.default
  ];

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
    # Neovim nixCats
    catsvim = {
      enable = true;
      nixpkgs_version = inputs.nixpkgs;
      packageNames =
        [ ]
        ++ (
          if cfg.enable then
            [
              "catsvim"
            ]
          else
            [ "catsvi" ]
        );
      packageDefinitions.replace = {
        catsvim =
          { ... }:
          {
            settings = {
              aliases = [
                "neovim-nixCats"
                "nvim-nixCats"
                "neovimCats"
                "nvimCats"
                "nx"
              ];
              configDirName = "nvim-nixCats";
            };
            categories = {
              general = true;
              extras = true;
              practice = true;
              undotree = true;
              welcome = true;
              opts = {
                theme = {
                  base16 = mkIf (cfg.theme == "stylix") {
                    enable = true;
                    table = stylix16;
                  };
                  name = cfg.theme;
                };
                # Pass configuration to obsidian.nvim
                # obsidian.workspaces = [
                #   {
                #     name = "Personal";
                #     path = config.xdg.userDirs.extraConfig.XDG_NOTES_DIR;
                #   }
                # ];
              };
            };
          };
        catsvi =
          { ... }:
          {
            settings = {
              aliases = [
                "neovim-nixCats"
                "nvim-nixCats"
                "neovimCats"
                "nvimCats"
                "nx"
              ];
              configDirName = "nvim-nixCats";
            };
            categories = {
              general = true;
              extras = true;
              practice = false;
              undotree = false;
              welcome = true;
              formatlint = true;
              opts = {
                theme = {
                  base16 = {
                    enable = true;
                    table = stylix16;
                  };
                  name = "gruvbox";
                };
                # Pass configuration to obsidian.nvim
                # obsidian.workspaces = [
                #   {
                #     name = "Personal";
                #     path = config.xdg.userDirs.extraConfig.XDG_NOTES_DIR;
                #   }
                # ];
              };
            };
          };
      };

    };
    home.sessionVariables = {
      CATSVIM = mkDefault (if cfg.enable then "catsvim" else "catsvi");
    };
    home.shellAliases = {
      n = "$CATSVIM";
    };
  };
}
