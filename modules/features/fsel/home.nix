{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.home.fsel;
in
{
  options.modules.home.fsel = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = true;
      description = "Whether to enable the Fsel application and clipboard launchers.";
    };

    package = lib.mkOption {
      type = lib.types.package;
      description = "Fsel package to install.";
    };

    cclipPackage = lib.mkOption {
      type = lib.types.package;
      description = "Cclip clipboard history package to install.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      cfg.cclipPackage
      cfg.package
    ];

    home.file.".config/fsel/config.toml".text = ''
      # Colors
      highlight_color = "Green"
      rounded_borders = true
      main_border_color = "Yellow"
      apps_border_color = "Orange"
      input_border_color = "Blue"
      cursor = "█"

      # App launcher
      terminal_launcher = "foot -e"

      [app_launcher]
      filter_desktop = true              # Filter apps by desktop environment
      list_executables_in_path = false   # Show CLI tools from $PATH
      hide_before_typing = false         # Hide list until you start typing
      match_mode = "fuzzy"               # "fuzzy" or "exact"
      confirm_first_launch = false       # Confirm before launching new apps with -p
    '';

    home.file.".local/bin/dmenu".source = "${cfg.package}/bin/fsel";
  };

}
