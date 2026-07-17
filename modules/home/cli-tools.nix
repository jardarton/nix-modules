_:
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.home.cli-tools;
in
{

  options.modules.home.cli-tools = {
    enable = mkOption {
      type = types.bool;
      default = true;
      example = true;
      description = "enable cli-tools";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      fd
      gh
      cmake
      cloc
      stow
      age
      sops
      ssh-to-age
      awscli
      tree
      fastfetch
      file
      findutils
      which
      gnutar
      rsync
      curl
      wget
      zip
      unzip
      xz
      zstd
      p7zip
      jq
      yq-go
      dust
      ripgrep
      dysk
      htop
      hyperfine
      watchexec
      nix-output-monitor
      nvd
      nix-tree
      nix-diff
      just
      tealdeer
    ];

    home.shellAliases = {
      nix-flake-init = "nix flake init --template github:hercules-ci/flake-parts#default";
    };
  };
}
