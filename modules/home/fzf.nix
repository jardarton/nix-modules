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
      colors = {
        #bg = "#${config.lib.stylix.colors.base00}";
        "bg+" = lib.mkForce "#ffffff";
        #"bg+" = "#${config.lib.stylix.colors.base0A}";
        #fg = "#d4d4d4";
        #"fg+" = "#d4d4d4";
      };
    };
    programs.zsh.initContent = lib.optionalString (!televisionEnabled) ''
      source <(fzf --zsh)
    '';
  };
}
