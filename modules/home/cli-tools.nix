{ localFlake, ... }:
{ config
, lib
, pkgs
, ...
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
      tree
      gnutar
      rsync
      dust
      fd
      ripgrep
      dysk
      htop
      cmake
      just
      tealdeer
    ];

    home.shellAliases = {
      nix-flake-init = "nix flake init --template github:hercules-ci/flake-parts#default";
    };
  };
}
