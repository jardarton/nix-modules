{ localFlake, withSystem, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.home.fsel;
in
{
  options.modules.home.fsel = with lib; {
    enable = mkOption {
      type = types.bool;
      default = true;
      example = true;
      description = "enable fsel ";
    };
  };

  imports = [
  ];

  config = lib.mkIf cfg.enable {
    home.packages = withSystem pkgs.stdenv.hostPlatform.system (
      { system, config, ... }:
      [
        config.packages.cclip
        localFlake.inputs.fsel.packages.${system}.default
      ]
    );

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

    home.file.".local/bin/dmenu".source = withSystem pkgs.stdenv.hostPlatform.system (
      { system, ... }: "${localFlake.inputs.fsel.packages.${system}.default}/bin/fsel"
    );
  };

}
