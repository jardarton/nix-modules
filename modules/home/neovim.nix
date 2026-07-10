{ localFlake, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.home.neovim;
in
{

  options.modules.home.neovim = {
    enable = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = "enable neovim";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      git
      gcc
      gnumake
      unzip
      wget
      curl
      tree-sitter
      ripgrep
      fd
      fzf
      cargo
      lazygit
      python3
      luajitPackages.luarocks
      lua54Packages.lua
      libxml2
      imagemagick
      impl # go iterface

      ## Formatters
      eslint_d
      fixjson
      prettierd
      yamlfmt
      gofumpt
      gomodifytags
      goimports-reviser
      nixfmt
      stylua
      sqruff
      sqlfluff
      #csharpier
      #csharp-ls

      ## Linters
      ansible-lint
      hadolint
      ktlint
      lua54Packages.luacheck
      markdownlint-cli
      yamllint

      ## Lsp's
      nixd
      svelte-language-server
      vtsls
      yaml-language-server
      #zls
      taplo-lsp
      tailwindcss-language-server
      marksman
      lua-language-server
      gopls
      dockerfile-language-server-nodejs
      bash-language-server
      #astro-language-server
      ansible-language-server
      rust-analyzer-unwrapped
      vscode-langservers-extracted

      #kotlin-language-server
      #jdt-language-server
      ## Debuggers
      lldb
      delve
      clang-tools

    ];

    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };
    home.file.".config/nvim" = {
      source = fetchGit {
        url = "https://github.com/jardarton/neovim.git";
        rev = "4c64fbfa9224a53f909c713bccacb59a9858f727";
        ref = "nixcats";
      };
      recursive = true;
    };
  };
}
