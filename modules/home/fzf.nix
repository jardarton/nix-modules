{ localFlake, ... }:
{ config, lib, ... }:
with lib;
let
  cfg = config.modules.home.fzf;
  televisionEnabled = attrByPath [ "modules" "home" "television" "enable" ] false config;
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
        fg = lib.mkForce "#${config.lib.stylix.colors.base05}";
        "bg+" = lib.mkForce "#${config.lib.stylix.colors.base02}";
        "fg+" = lib.mkForce "#${config.lib.stylix.colors.base06}";
        hl = lib.mkForce "#${config.lib.stylix.colors.base0A}";
        "hl+" = lib.mkForce "#${config.lib.stylix.colors.base0A}";
        border = lib.mkForce "#${config.lib.stylix.colors.base03}";
        prompt = lib.mkForce "#${config.lib.stylix.colors.base0D}";
        pointer = lib.mkForce "#${config.lib.stylix.colors.base09}";
        marker = lib.mkForce "#${config.lib.stylix.colors.base0B}";
        info = lib.mkForce "#${config.lib.stylix.colors.base0C}";
        spinner = lib.mkForce "#${config.lib.stylix.colors.base0E}";
      };
    };
    programs.zsh.initContent = lib.optionalString (!televisionEnabled) ''
      source <(fzf --zsh)
    '';
  };
}
