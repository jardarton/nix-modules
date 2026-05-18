{ localFlake }:
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  inherit (pkgs.stdenv) isLinux;
  cfg = config.modules.shared.stylix;
in
{
  options.modules.shared.stylix = {
    enable = mkOption {
      type = types.bool;
      default = true;
      example = true;
      description = "stylix for whole system";
    };
    theme = mkOption {
      type = types.str;
      default = "kanagawa";
      example = "gruvbox-dark-hard";
      description = "base 16 theme name";
    };
    wallpaper = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "path to wallpaper";
    };
    monospaceFont = mkOption {
      type = types.nullOr types.str;
      default = "Monaspace Radon";
      description = "monaspace github font name";
    };

  };

  # stylix.base16Scheme = builtins.fetchurl {
  #   url = "https://raw.githubusercontent.com/scottmckendry/cyberdream.nvim/main/extras/base16/cyberdream.yaml";
  #   sha256 = "1bfi479g7v5cz41d2s0lbjlqmfzaah68cj1065zzsqksx3n63znf";
  # };

  imports = [ localFlake.inputs.stylix.nixosModules.stylix ];

  config = mkIf cfg.enable {
    stylix.enable = true;
    stylix.image = mkDefault cfg.wallpaper;
    stylix.base16Scheme = mkDefault "${pkgs.base16-schemes}/share/themes/${cfg.theme}.yaml";
    stylix.polarity = mkDefault "dark";
    stylix.opacity = {
      applications = 1.0;
      terminal = 1.0;
      desktop = 1.0;
    };
    stylix.fonts = {
      serif = {
        package = pkgs.monaspace;
        name = cfg.monospaceFont;
      };
      sansSerif = {
        package = pkgs.monaspace;
        name = cfg.monospaceFont;
      };
      monospace = {
        package = pkgs.monaspace;
        name = cfg.monospaceFont;
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };
  };
}
