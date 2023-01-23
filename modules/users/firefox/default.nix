{ pkgs
, config
, lib
, ...
}@inputs:
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
      default = !inputs.config.xsession.enable;
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
      home.packages = with pkgs; [
        nyxt
        firefox
        google-chrome
      ];

      programs.chromium = {
        enable = true;
        package = pkgs.ungoogled-chromium;
        commandLineArgs = [
          "--no-default-browser-check"
          "--no-first-run"
        ];
        extensions = [
          { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
          { id = "fnaicdffflnofjppbagibeoednhnbjhg"; } # floccus
          { id = "nngceckbapebfimnlniiiahkandclblb"; } # bitwarden
          { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; } # dark reader
          { id = "egpjdkipkomnmjhjmdamaniclmdlobbo"; } # firenvim
          { id = "lckanjgmijmafbedllaakclkaicjfmnk"; } # clear urls
          { id = "fihnjjcciajhdojfnbdddfaoknhalnja"; } # i don't care about cookies
          { id = "fhcgjolkccmbidfldomjliifgaodjagh"; } # cookie auto delete
          { id = "ajopnjidmegmdimjlfnijceegpefgped"; } # better ttv
          { id = "kbmfpngjjgdllneeigpgjifpgocmfgmb"; } # reddit reddit enhancement suite
          { id = "ikhahkidgnljlniknmendeflkdlfhonj"; } # no pdf download
          { id = "oocalimimngaihdkbihfgmpkcpnmlaoa"; } # teleparty
          { id = "bkkmolkhemgaeaeggcmfbghljjjoofoh"; } # catppuccin mocha theme
          {
            id = "dcpihecpambacapedldabdbpakmachpb";
            updateUrl = "https://raw.githubusercontent.com/iamadamdev/bypass-paywalls-chrome/master/updates.xml";
          }
        ];
      };

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
          terms-of-service-didnt-read
          ublock-origin
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
              "browser.url.placeHolderName" = "DuckDuckGo";

              "network.cookieBehaviour" = 5;
              "network.cookie.lifetimePolicy" = 2;
              "network.dns.disablePrefetch" = false;
              "network.predictor.enabled" = true;
              "network.prefetch-next" = true;

              "privacy.trackingprotection.enabled" = true;
              "privacy.trackingprotection.socialtracking.enabled" = true;

              "signon.rememberSignons" = false;
            };
          };
        };
      };
    };
}
