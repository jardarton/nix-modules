{ localFlake, ... }:
{
  config,
  lib,
  options,
  ...
}:
with lib;
let
  cfg = config.modules.home.fzf;
  televisionEnabled = attrByPath [ "modules" "home" "television" "enable" ] false config;
  stylix = import ./lib/stylix.nix { inherit config options; };
in
{

  options.modules.home.fzf = {
    enable = mkOption {
      type = types.bool;
      default = true;
      example = true;
      description = "enable fzf";
    };
  };

  config = mkIf cfg.enable {
    programs.fzf = {
      enable = true;
      enableZshIntegration = lib.mkForce (!televisionEnabled);
      defaultOptions = [ "--layout=reverse-list" ];
      colors = {
        bg = lib.mkForce "-1";
        fg = lib.mkForce (stylix.withHashtag "base05");
        "bg+" = lib.mkForce (stylix.withHashtag "base02");
        "fg+" = lib.mkForce (stylix.withHashtag "base06");
        hl = lib.mkForce (stylix.withHashtag "base0A");
        "hl+" = lib.mkForce (stylix.withHashtag "base0A");
        border = lib.mkForce (stylix.withHashtag "base03");
        prompt = lib.mkForce (stylix.withHashtag "base0D");
        pointer = lib.mkForce (stylix.withHashtag "base09");
        marker = lib.mkForce (stylix.withHashtag "base0B");
        info = lib.mkForce (stylix.withHashtag "base0C");
        spinner = lib.mkForce (stylix.withHashtag "base0E");
      };
    };
    programs.zsh.initContent = lib.optionalString (!televisionEnabled) ''
      source <(fzf --zsh)
    '';
  };
}
