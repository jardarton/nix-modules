{
  config,
  lib,
  ...
}:
let
  moduleFlake = config.nixModules.sourceFlake;
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
  options.nixModules.stylixHelper = lib.mkOption {
    type = lib.types.deferredModule;
    description = ''
      Home Manager module that exposes `config.lib.nixModules.stylix`, the
      Stylix colour helpers with a Kanagawa fallback for configurations
      without Stylix. Features that theme themselves import it. Only use it
      inside option values; test `options ? stylix` to decide which
      attributes to define, because reading `config.lib` there recurses.
    '';
  };

  config.nixModules.stylixHelper = {
    # Several features import this; the key lets the module system keep one.
    key = "nix-modules#stylix-helper";
    imports = [
      (
        { config, options, ... }:
        {
          lib.nixModules.stylix = import ./stylix/lib.nix { inherit config options; };
        }
      )
    ];
  };

  config.flake.modules = {
    homeManager.stylix = mkStylixModule {
      description = "Whether to enable Stylix for the whole home configuration.";
      extraConfig.stylix.targets.gnome.enable = false;
      stylixModule = moduleFlake.inputs.stylix.homeModules.stylix;
    };

    nixos.stylix = mkStylixModule {
      description = "Whether to enable Stylix for the whole system.";
      stylixModule = moduleFlake.inputs.stylix.nixosModules.stylix;
    };
  };

  # Export groups evaluated together by this flake's module checks.
  config.nixModules.checkCompositions.homeManager.graphical = [ "stylix" ];
  config.nixModules.checkCompositions.homeManager."browser-minimal" = [ "stylix" ];
  config.nixModules.checkCompositions.nixos."laptop-kanata" = [ "stylix" ];
  config.nixModules.checkCompositions.nixos."laptop-keyd" = [ "stylix" ];
  config.nixModules.checkCompositions.nixos.server = [ "stylix" ];
}
