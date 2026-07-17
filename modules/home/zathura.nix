_:
{ lib, config, ... }:
with lib;
let
  cfg = config.modules.home.zathura;
in
{

  options.modules.home.zathura = {
    enable = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = "enable zathura";
    };
  };

  config = mkIf cfg.enable {
    programs.zathura = {
      enable = true;
      extraConfig = ''
        set selection-clipboard clipboard
      '';
    };

    programs.sioyek = {
      enable = true;
    };

    xdg.mimeApps.defaultApplications = {
      "application/pdf" = "org.pwmt.zathura.desktop";
    };
  };
}
