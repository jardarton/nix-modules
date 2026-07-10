{ localFlake, ... }:
{ pkgs
, lib
, config
, options
, ...
}:
with lib;
let
  cfg = config.modules.home.kitty;
  stylix = import ./lib/stylix.nix { inherit config options; };
in
{

  options.modules.home.kitty = {
    enable = mkOption {
      type = types.bool;
      default = true;
      example = true;
      description = "enable kitty";
    };
    opacity = mkOption {
      type = types.float;
      example = 1.0;
      default = 1.0;
    };
  };

  config = mkIf cfg.enable ({
    programs.kitty = {
      enable = true;
      shellIntegration.enableZshIntegration = true;
      settings = {
        #font_family = "family='Monaspace Krypton Var' variable_name=MonaspaceKryptonVar style=MonaspaceKryptonVar-Regular";
        bold_font = "auto";
        italic_font = "auto";
        bold_italic_font = "auto";

        cursor_trail = 1;
        cursor_shape_unfocused = "hollow";

        hide_window_decorations = "yes";
        scrollback_lines = "100000";
        scrollback_pager_history_size = "256";

        copy_on_select = "yes";

        disable_ligatures = "cursor";

        background_opacity = mkForce cfg.opacity;
        background_blur = if cfg.opacity == 1.0 then 0 else 32;

        allow_hyperlinks = "yes";

        enable_audio_bell = "no";

        cursor_blink_interval = "0";

        close_on_child_death = "yes";
      };
    };
  }
  // optionalAttrs stylix.hasStylix {
    stylix.targets.kitty.variant256Colors = true;
  });
}
