{
  firefox-addons,
  ...
}:
{
  id = 0;
  isDefault = true;

  extensions.packages = with firefox-addons; [
    ublock-origin
    sponsorblock
    istilldontcareaboutcookies
  ];

  extraConfig = builtins.concatStringsSep "\n" [
    (builtins.readFile ./betterfox/Securefox.js)
    (builtins.readFile ./betterfox/Fastfox.js)
  ];

  settings = {
    "browser.translations.neverTranslateLanguages" = "no";

    "extensions.autoDisableScopes" = 0;
    "browser.startup.homepage" = "https://www.google.com";
    "browser.tabs.inTitlebar" = 1;
    "browser.tabs.warnOnClose" = false;
    "browser.sessionstore.interval" = 600000; # 10 min session saveistead of 15sec
    "browser.download.animateNotifications" = false;
    "browser.theme.dark-private-windows" = true;
    "browser.toolbars.bookmarks.visibility" = false;
    "app.normandy.api_url" = "";
    "apz.gtk.kinetic_scroll.enabled" = false;
    "apz.overscroll.enabled" = false;
    "browser.aboutConfig.showWarning" = false;
    "browser.shell.checkDefaultBrowser" = false;
    "extensions.htmlaboutaddons.recommendations.enabled" = false;
    "privacy.trackingprotection.enabled" = true;
    "privacy.userContext.enabled" = true;
    "privacy.userContext.ui.enabled" = true;
    "privacy.window.name.update.enabled" = true;

    #sidebar (using sideberry via textfox)
    "sidebar.verticalTabs" = true;
    "sidebar.new-sidebar.has-used" = true;
    "sidebar.revamp" = true;
    "sidebar.visibility" = "hide-sidebar";
    "sidebar.main.tools" = "history,bookmarks";

    #style
    "widget.windows.mica" = true;
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    "browser.tabs.allow_transparent_browser" = true;
    "widget.macos.titlebar-blend-mode.behind-window" = true;
    "browser.theme.native-theme" = false;
    "browser.taskbar.lists.recent.enabled" = false;
    "browser.taskbar.lists.frequent.enabled" = false;
    "browser.taskbar.lists.enabled" = false;
    "browser.taskbar.lists.tasks.enabled" = false;
    "layout.css.has-selector.enabled" = true;
    "svg.context-properties.content.enabled" = true;

    # This allows firefox devs changing options for a small amount of users to test out stuff.
    # Not with me please ...
    "app.normandy.enabled" = false;
    "app.shield.optoutstudies.enabled" = false;

    "beacon.enabled" = false; # No bluetooth location BS in my webbrowser please
    "device.sensors.enabled" = false; # This isn't a phone
    "geo.enabled" = false; # Disable geolocation alltogether

    # Disable telemetry for privacy reasons
    "toolkit.telemetry.archive.enabled" = false;
    "toolkit.telemetry.enabled" = false; # enforced by nixos
    "toolkit.telemetry.bkrPing.enabled" = false;
    "toolkit.telemetry.updatePing.enabled" = false;
    "toolkit.telemetry.firstShutdownPing.enabled" = false;
    "toolkit.telemetry.shutdownPingSender.enabled" = false;
    "toolkit.telemetry.newProfilePing.enabled" = false;
    "toolkit.telemetry.server" = "";
    "toolkit.telemetry.unified" = false;
    "extensions.webcompat-reporter.enabled" = false; # don't report compability problems to mozilla
    "datareporting.policy.dataSubmissionEnabled" = false;
    "datareporting.healthreport.uploadEnabled" = false;
    "browser.ping-centre.telemetry" = false;
    "browser.urlbar.eventTelemetry.enabled" = false; # (default)

    # Disable some useless stuff
    "extensions.pocket.enabled" = false; # disable pocket, save links, send tabs
    "extensions.abuseReport.enabled" = false; # don't show 'report abuse' in extensions
    "extensions.formautofill.creditCards.enabled" = false; # don't auto-fill credit card information
    "identity.fxaccounts.enabled" = false; # disable firefox login
    "identity.fxaccounts.toolbar.enabled" = false;
    "identity.fxaccounts.pairing.enabled" = false;
    "identity.fxaccounts.commands.enabled" = false;
    "browser.contentblocking.report.lockwise.enabled" = false; # don't use firefox password manger
    "browser.uitour.enabled" = false; # no tutorial please
    "browser.newtabpage.activity-stream.telemetry" = false;
    "browser.newtabpage.activity-stream.feeds.telemetry" = false;
    "browser.newtabpage.activity-stream.showSponsored" = false;
    "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;

    # disable annoying web features
    "dom.push.enabled" = false; # no notifications, really...
    "dom.push.connection.enabled" = false;
    "dom.battery.enabled" = false; # you don't need to see my battery...
    "dom.private-attribution.submission.enabled" = false; # No PPA for me pls

    "media.ffmpeg.vaapi.enabled" = true; # https://wiki.archlinux.org/title/firefox#Hardware_video_acceleration
    "media.ffvpx.enabled" = false; # https://wiki.archlinux.org/title/firefox#Hardware_video_acceleration
    #will this impact perf
    "gfx.webrender.compositor.force-enabled" = false;
  };

  # userContent = ''
  #                   :root {
  #     --in-content-page-background: #00000000 !important;
  #     --in-content-box-background: #00000088 !important;
  #   }
  # '';

  userChrome = ''
                            :root { --tabpanel-background-color: transparent !important; }
                                #browser {
                              background-color: transparent !important;
                            }
                            #navigator-toolbox{ --toolbar-bgcolor: transparent !important}

                            .browser-toolbox-background {
                              background-color: transparent !important;

    }
                            #sidebar-main {
                        var(--lwt-additional-images,none), var(--lwt-header-image, none) !important;
                        background-color: transparent !important
                    }
  '';

}
