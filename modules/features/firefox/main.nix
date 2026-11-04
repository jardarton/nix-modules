# The full browser: textfox, Vimium and productivity add-ons on top of the
# shared core. Stays close to stock arkenfox apart from what core.nix relaxes.
{
  config,
  lib,
  options,
  ...
}:
let
  inherit (lib) mkDefault mkIf;
  cfg = config.modules.home.firefox;
  stylix = import ../stylix/lib.nix { inherit config options; };
in
{
  imports = [
    ./core.nix
    ./vimium.nix
  ];

  config = mkIf cfg.enable {
    modules.home.firefox.variant = "main";

    textfox = {
      enable = mkDefault true;
      profiles = [ cfg.profile ];
      config = {
        tabs = {
          horizontal.enable = false;
          vertical.enable = true;
        };
        icons = {
          toolbar.extensions.enable = true;
          context.extensions.enable = true;
          context.firefox.enable = true;
        };
        font.size = "16px";
        background.color = stylix.withHashtag "base00";
        border = {
          color = stylix.withHashtag "base0A";
          width = "2px";
          transition = "1.0s ease";
          radius = "5px";
        };
      };
    };

    programs.firefox.profiles.${cfg.profile} = {
      extensions.packages = with cfg.addons; [
        vimium
        sponsorblock
        darkreader
        istilldontcareaboutcookies
        firefox-color
        bitwarden
      ];

      settings = lib.mapAttrs (_: mkDefault) {
        # Open the homepage at startup instead of arkenfox's blank page, so
        # setting `browser.startup.homepage` is enough.
        "browser.startup.page" = 1;
        "browser.aboutConfig.showWarning" = false;

        # Look: vertical tabs in the sidebar, styled by textfox.
        "sidebar.verticalTabs" = true;
        "sidebar.revamp" = true;
        "sidebar.new-sidebar.has-used" = true;
        "sidebar.visibility" = "hide-sidebar";
        "sidebar.main.tools" = "history,bookmarks";
        "browser.tabs.inTitlebar" = 1;
        "browser.toolbars.bookmarks.visibility" = "never";
        "browser.theme.native-theme" = false;
        "browser.tabs.allow_transparent_browser" = true;
        "widget.windows.mica" = true;
        "widget.macos.titlebar-blend-mode.behind-window" = true;

        # Scrolling without kinetic momentum or overscroll bounce.
        "apz.gtk.kinetic_scroll.enabled" = false;
        "apz.overscroll.enabled" = false;
      };

      userContent = ''
        @-moz-document url(about:newtab), url("about:home") { html{ --newtab-background-color: transparent !important; --newtab-background-color-secondary: transparent !important; } }
      '';

      userChrome = ''
        #firefox-view-button {
          display: none !important;
        }
      '';
    };
  };
}
