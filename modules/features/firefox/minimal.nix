# A private, minimal browser on top of the shared core. It relaxes the arkenfox
# defaults that would surprise someone who just wants to browse.
{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkDefault mkIf;
  cfg = config.modules.home.firefox;
in
{
  imports = [ ./core.nix ];

  config = mkIf cfg.enable {
    modules.home.firefox.variant = "minimal";

    programs.firefox = {
      # uBlock Origin's cookie-notice lists replace a separate cookie-banner
      # add-on. Overwriting the selection also restores uBO's defaults.
      policies."3rdparty".Extensions."uBlock0@raymondhill.net".toOverwrite.filterLists = mkDefault [
        "user-filters"
        "ublock-filters"
        "ublock-badware"
        "ublock-privacy"
        "ublock-quick-fixes"
        "ublock-unbreak"
        "easylist"
        "easyprivacy"
        "urlhaus-1"
        "plowe-0"
        "fanboy-cookiemonster"
        "ublock-cookies-easylist"
      ];

      profiles.${cfg.profile}.settings = lib.mapAttrs (_: mkDefault) {
        # Reopen the previous session and show Firefox Home on new tabs.
        # Sponsored content there is off by policy.
        "browser.startup.page" = 3;
        "browser.newtabpage.enabled" = true;

        # Search suggestions while typing in the address bar.
        "browser.search.suggest.enabled" = true;
        "browser.urlbar.suggest.searches" = true;

        # Save downloads straight to the Downloads folder.
        "browser.download.useDownloadDir" = true;
        "browser.download.always_ask_before_handling_new_types" = false;

        # Fill in saved passwords automatically.
        "signon.autofillForms" = true;
      };
    };
  };
}
