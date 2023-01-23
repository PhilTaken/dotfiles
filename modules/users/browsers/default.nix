{ pkgs
, config
, lib
, ...
}@inputs:
with lib;

let cfg = config.phil.browsers;
in
{
  options.phil.browsers = {
    enableAll = mkOption {
      description = "Enable browsers";
      type = types.bool;
      default = true;
    };

    chromium = {
      enable = mkOption {
        description = "enable chromium";
        type = types.bool;
        default = cfg.enableAll;
      };
    };

    qutebrowser = {
      enable = mkOption {
        description = "enable qutebrowser";
        type = types.bool;
        default = cfg.enableAll;
      };
    };

    firefox = {
      enable = mkOption {
        description = "enable firefox";
        type = types.bool;
        default = cfg.enableAll;
      };

      wayland = mkOption {
        description = "Force wayland for firefox";
        type = types.bool;
        default = !inputs.config.xsession.enable;
      };

      librewolf = mkOption {
        description = "use librewolf instead";
        type = types.bool;
        default = true;
      };
    };
  };

  config =
    let
      pkg = if cfg.firefox.librewolf then pkgs.librewolf else pkgs.firefox;
      waylandpkg = if cfg.firefox.librewolf then pkgs.librewolf-wayland else pkgs.firefox-wayland;
    in {
      home.packages = with pkgs; lib.optionals cfg.enableAll [
        nyxt
        google-chrome
      ];

      programs.chromium = {
        inherit (cfg.chromium) enable;
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
        inherit (cfg.firefox) enable;

        package = if cfg.firefox.wayland then waylandpkg else pkg;
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

      programs.qutebrowser = {
        inherit (cfg.qutebrowser) enable;

        enableDefaultBindings = true;

        quickmarks = {
          nixpkgs = "https://github.com/NixOS/nixpkgs";
          home-manager = "https://github.com/nix-community/home-manager";
        };

        searchEngines = {
          w = "https://en.wikipedia.org/wiki/Special:Search?search={}&go=Go&ns0=1";
          aw = "https://wiki.archlinux.org/?search={}";
          nw = "https://nixos.wiki/index.php?search={}";
          g = "https://www.google.com/search?hl=en&q={}";
        };
      };
    };
}
