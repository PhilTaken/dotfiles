{ pkgs
, config
, lib
, ...
}:
with lib;

let cfg = config.phil.firefox;
in
{
  options.phil.firefox = {
    enable = mkOption {
      description = "Enable firefox";
      type = types.bool;
      default = true;
    };

    wayland = mkOption {
      description = "Force wayland";
      type = types.bool;
      default = true;
    };

    librewolf = mkOption {
      description = "use librewolf instead";
      type = types.bool;
      default = true;
    };
  };

  config =
    let
      pkg = if cfg.librewolf then pkgs.librewolf else pkgs.firefox;
      waylandpkg = if cfg.librewolf then pkgs.librewolf-wayland else pkgs.firefox-wayland;
    in
    (mkIf cfg.enable) {
      programs.firefox = {
        enable = true;

        package = if cfg.wayland then waylandpkg else pkg;
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          betterttv
          bitwarden
          canvasblocker
          clearurls
          cookie-autodelete
          floccus
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
    };
}
