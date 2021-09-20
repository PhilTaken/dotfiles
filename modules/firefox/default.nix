{ pkgs
, username
, enable_xorg
, ...
}: {
  programs.firefox = {
    enable = true;
    package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
      forceWayland = !enable_xorg;
      extraPolicies = {
        ExtensionSettings = { };
      };
    };

    extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      betterttv
      bitwarden
      canvasblocker
      clearurls
      cookie-autodelete
      floccus
      https-everywhere
      i-dont-care-about-cookies
      matte-black-red
      netflix-1080p
      no-pdf-download
      privacy-badger
      reddit-enhancement-suite
      stylus
      terms-of-service-didnt-read
      ublock-origin
      unpaywall
      zoom-redirector
      privacy-redirect
    ];

    profiles = {
      home = {
        id = 0;
        settings = {
          "accessibility.typeaheadfind.flashBar" = 0;

          "app.update.auto" = false;

          "browser.contentblocking.category" = "strict";
          "browser.discovery.enabled" = false;
          "browser.shell.checkDefaultBrowser" = false;
          "browser.startup.homepage" = "https://now.hackertab.dev/"; # TODO add as extension
          "browser.url.placeHolderName" = "DuckDuckGo";

          "network.cookieBehaviour" = 5;
          "network.cookie.lifetimePolicy" = 2;
          "network.dns.disablePrefetch" = true;
          "network.predictor.enabled" = false;
          "network.prefetch-next" = false;

          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;

          "signon.rememberSignons" = false;
        };
      };
    };
  };
}
