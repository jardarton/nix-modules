# Shared by homeModules.firefox and homeModules.firefox-minimal: options,
# arkenfox, debloating policies, uBlock Origin and desktop integration.
{
  config,
  lib,
  options,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkDefault
    mkIf
    mkMerge
    mkOption
    optionalAttrs
    types
    ;
  cfg = config.modules.home.firefox;
  defaults = lib.mapAttrs (_: mkDefault);
in
{
  options.modules.home.firefox = {
    enable = mkOption {
      type = types.bool;
      default = true;
      example = false;
      description = "Whether to configure Firefox.";
    };

    profile = mkOption {
      type = types.str;
      default = "default";
      example = "alternate";
      description = ''
        Name of the Firefox profile to configure. It is also the profile's
        directory name, so changing it starts a new, empty profile.
      '';
    };

    addons = mkOption {
      type = types.attrsOf types.package;
      description = "Firefox add-on packages available to the profile, normally rycee's firefox-addons.";
    };

    arkenfox = mkOption {
      type = types.path;
      description = ''
        The arkenfox `user.js` written at the top of the profile's `user.js`.
        Profile `settings` come after it, so they override arkenfox.
      '';
    };

    variant = mkOption {
      type = types.enum [
        "main"
        "minimal"
      ];
      readOnly = true;
      internal = true;
      description = ''
        Which export configured Firefox. Set by homeModules.firefox and
        homeModules.firefox-minimal, so importing both is an error.
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      # Reading the option is what reports a double definition.
      assertions = [
        {
          assertion = builtins.elem cfg.variant [
            "main"
            "minimal"
          ];
          message = "Import only one of homeModules.firefox and homeModules.firefox-minimal.";
        }
      ];

      programs.firefox = {
        enable = true;

        # The same cached Firefox, minus ONNX Runtime's OpenVINO provider and
        # symbol tables. See firefox-unwrapped-slim.pkg.nix. PipeWire already
        # brings headless ffmpeg, which keeps VA-API decoding, so the wrapper
        # does not need a second, full ffmpeg.
        package = mkIf pkgs.stdenv.hostPlatform.isLinux (
          mkDefault (
            (pkgs.wrapFirefox.override { ffmpeg_9 = pkgs.ffmpeg_9-headless; }) (pkgs.callPackage
              ./firefox-unwrapped-slim.pkg.nix
              { }
            ) { }
          )
        );

        # Firefox keeps using the legacy root when it already exists, and
        # existing profiles live there. Consumers can opt into the XDG path.
        configPath = mkIf (!pkgs.stdenv.hostPlatform.isDarwin) (mkDefault ".mozilla/firefox");

        # Enforced by Firefox itself, so they keep working when Mozilla
        # renames the underlying preferences.
        policies = defaults {
          DisableTelemetry = true;
          DisableFirefoxStudies = true;
          DisableFirefoxAccounts = true;
          DisableFeedbackCommands = true;
          DisableFirefoxScreenshots = true;
          DisableProfileImport = true;
          DisableProfileRefresh = true;
          DisableSetDesktopBackground = true;
          AutofillAddressEnabled = false;
          AutofillCreditCardEnabled = false;
          BrowserDataBackup = {
            AllowBackup = false;
            AllowRestore = false;
          };
          IPProtectionAvailable = false;
          VisualSearchEnabled = false;
          DontCheckDefaultBrowser = true;
          NoDefaultBookmarks = true;
          OverrideFirstRunPage = "";
          OverridePostUpdatePage = "";
          SkipTermsOfUse = true;
          FirefoxHome = {
            SponsoredTopSites = false;
            Stories = false;
            SponsoredStories = false;
            Weather = false;
            Locked = false;
          };
          FirefoxSuggest = {
            WebSuggestions = false;
            SponsoredSuggestions = false;
            ImproveSuggest = false;
            OnlineEnabled = false;
            Locked = false;
          };
          UserMessaging = {
            WhatsNew = false;
            ExtensionRecommendations = false;
            FeatureRecommendations = false;
            UrlbarInterventions = false;
            SkipOnboarding = true;
            MoreFromMozilla = false;
            FirefoxLabs = false;
            Locked = false;
          };
          # Block the AI features but keep on-device translation.
          AIControls = {
            Default = {
              Value = "blocked";
              Locked = false;
            };
            Translations = {
              Value = "available";
              Locked = false;
            };
          };
          Permissions = {
            Location.BlockNewRequests = true;
            Notifications.BlockNewRequests = true;
          };
        };

        profiles.${cfg.profile} = {
          id = mkDefault 0;
          isDefault = mkDefault true;
          preConfig = builtins.readFile cfg.arkenfox;
          extensions.packages = [ cfg.addons.ublock-origin ];

          # Overrides of arkenfox shared by both browsers.
          settings = defaults {
            # Enable the add-ons Home Manager installs without asking.
            "extensions.autoDisableScopes" = 0;
            # arkenfox clears cookies when Firefox closes, which signs out of
            # every site. Keep them; cache and form data are still cleared.
            "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
            # The push service keeps a connection to Mozilla open, and site
            # notifications are blocked by policy anyway.
            "dom.push.enabled" = false;
            # Promotions for Mozilla's other products.
            "browser.vpn_promo.enabled" = false;
            "browser.promo.pin.enabled" = false;
            "browser.promo.relay.enabled" = false;
            "signon.firefoxRelay.feature" = "disabled";
            "browser.contentblocking.report.hide_vpn_banner" = true;
            # The profile switcher in the menu. Home Manager manages profiles.
            "browser.profiles.enabled" = false;
            "browser.translations.neverTranslateLanguages" = "no";
          };
        };
      };

      xdg.mimeApps.defaultApplications = defaults {
        "text/html" = [ "firefox.desktop" ];
        "text/xml" = [ "firefox.desktop" ];
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
      };
    }
    (optionalAttrs (options ? stylix) {
      stylix.targets.firefox = {
        enable = mkDefault true;
        profileNames = [ cfg.profile ];
      };
    })
  ]);
}
