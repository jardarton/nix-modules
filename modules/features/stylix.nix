{
  config,
  inputs,
  self,
  ...
}:
let
  moduleFlake = inputs.nix-modules or self;
  tintedSchemes = moduleFlake.inputs.stylix.inputs.tinted-schemes;

  mkStylixModule =
    {
      description,
      extraConfig ? { },
      stylixModule,
    }:
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib)
        mkDefault
        mkIf
        mkMerge
        mkOption
        types
        ;
      cfg = config.modules.shared.stylix;
    in
    {
      imports = [ stylixModule ];

      options.modules.shared.stylix = {
        enable = mkOption {
          type = types.bool;
          default = true;
          example = true;
          inherit description;
        };
        theme = mkOption {
          type = types.str;
          default = "kanagawa";
          example = "gruvbox-dark-hard";
          description = "Base16 theme name.";
        };
        wallpaper = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = "Path to the wallpaper.";
        };
        monospaceFont = mkOption {
          type = types.nullOr types.str;
          default = "Monaspace Radon";
          description = "Monaspace font name used for the configured font families.";
        };
      };

      config = mkIf cfg.enable (mkMerge [
        {
          stylix = {
            enable = true;
            image = mkDefault cfg.wallpaper;
            base16Scheme = mkDefault "${tintedSchemes}/base16/${cfg.theme}.yaml";
            polarity = mkDefault "dark";
            opacity = {
              applications = 1.0;
              terminal = 1.0;
              desktop = 1.0;
            };
            fonts = {
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
        extraConfig
      ]);
    };
in
{
  reusableModules = {
    home.stylix = mkStylixModule {
      description = "Whether to enable Stylix for the whole home configuration.";
      extraConfig.stylix.targets.gnome.enable = false;
      stylixModule = moduleFlake.inputs.stylix.homeModules.stylix;
    };

    nixos.stylix = mkStylixModule {
      description = "Whether to enable Stylix for the whole system.";
      stylixModule = moduleFlake.inputs.stylix.nixosModules.stylix;
    };
  };

  flake = {
    homeModules.stylix = config.reusableModules.home.stylix;
    nixosModules.stylix = config.reusableModules.nixos.stylix;
  };
}
