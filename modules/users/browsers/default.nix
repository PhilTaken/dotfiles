{
  pkgs,
  config,
  lib,
  ...
}@inputs:
let
  cfg = config.phil.browsers;
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;
in
{
  options.phil.browsers = {
    enable = mkEnableOption "browsers";

    chromium = {
      enable = mkOption {
        description = "enable chromium";
        type = types.bool;
        default = !lib.hasInfix "darwin" pkgs.stdenv.hostPlatform.system;
      };
    };

    qutebrowser = {
      enable = mkOption {
        description = "enable qutebrowser";
        type = types.bool;
        default = true;
      };
    };

    firefox = {
      enable = mkOption {
        description = "enable firefox";
        type = types.bool;
        default = !lib.hasInfix "darwin" pkgs.stdenv.hostPlatform.system;
      };

      wayland = mkOption {
        description = "Force wayland for firefox";
        type = types.bool;
        default = !inputs.config.xsession.enable;
      };

      librewolf = mkOption {
        description = "use librewolf instead";
        type = types.bool;
        default = false;
      };
    };
  };

  config =
    let
      pkg = if cfg.firefox.librewolf then pkgs.librewolf else pkgs.firefox;
      waylandpkg = if cfg.firefox.librewolf then pkgs.librewolf-wayland else pkgs.firefox-wayland;
    in
    mkIf cfg.enable {
      programs.chromium = {
        inherit (cfg.chromium) enable;
        #package = pkgs.ungoogled-chromium;
        commandLineArgs = [
          "--no-default-browser-check"
          #"--no-first-run"
        ];
        extensions = [
          { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
          { id = "fnaicdffflnofjppbagibeoednhnbjhg"; } # floccus
          { id = "nngceckbapebfimnlniiiahkandclblb"; } # bitwarden
          { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; } # dark reader
          { id = "lckanjgmijmafbedllaakclkaicjfmnk"; } # clear urls
          { id = "fihnjjcciajhdojfnbdddfaoknhalnja"; } # i don't care about cookies

          { id = "igeehkedfibbnhbfponhjjplpkeomghi"; } # tabli tab manager (using bookmarks)
          { id = "iaiomicjabeggjcfkbimgmglanimpnae"; } # tab session manager

          { id = "bkkmolkhemgaeaeggcmfbghljjjoofoh"; } # catppuccin mocha theme
          { id = "mmjbdbjnoablegbkcklggeknkfcjkjia"; } # new tab page
          { id = "fhcgjolkccmbidfldomjliifgaodjagh"; } # cookie auto delete
          { id = "ikhahkidgnljlniknmendeflkdlfhonj"; } # no pdf download

          { id = "egpjdkipkomnmjhjmdamaniclmdlobbo"; } # firenvim
          { id = "ajopnjidmegmdimjlfnijceegpefgped"; } # better ttv
          { id = "kbmfpngjjgdllneeigpgjifpgocmfgmb"; } # reddit reddit enhancement suite
          { id = "oocalimimngaihdkbihfgmpkcpnmlaoa"; } # teleparty
          {
            id = "dcpihecpambacapedldabdbpakmachpb";
            updateUrl = "https://raw.githubusercontent.com/iamadamdev/bypass-paywalls-chrome/master/updates.xml";
          }
        ];
      };

      programs.firefox = {
        inherit (cfg.firefox) enable;

        package = if cfg.firefox.wayland then waylandpkg else pkg;
        profiles = {
          home = {
            id = 0;

            extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
              betterttv
              bitwarden
              canvasblocker
              clearurls
              cookie-autodelete
              floccus
              i-dont-care-about-cookies
              matte-black-red
              no-pdf-download
              privacy-badger
              reddit-enhancement-suite
              terms-of-service-didnt-read
              ublock-origin
            ];

            search = {
              default = "ddg";
              engines = {
                "Nix Packages" = {
                  urls = [
                    {
                      template = "https://search.nixos.org/packages";
                      params = [
                        {
                          name = "type";
                          value = "packages";
                        }
                        {
                          name = "query";
                          value = "{searchTerms}";
                        }
                      ];
                    }
                  ];

                  icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  definedAliases = [ "@np" ];
                };

                "NixOS Wiki" = {
                  urls = [ { template = "https://nixos.wiki/index.php?search={searchTerms}"; } ];
                  icon = "https://nixos.wiki/favicon.png";
                  updateInterval = 24 * 60 * 60 * 1000; # every day
                  definedAliases = [ "@nw" ];
                };

                "bing".metaData.hidden = true;
                "google".metaData.alias = "@g"; # builtin engines only support specifying one additional alias
              };
              force = true;
              order = [
                "ddg"
                "google"
              ];
            };
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

        settings = {
          auto_save.session = true;
          session.lazy_restore = true;
          content.fullscreen.window = true;
          content.pdfjs = true;
          downloads.location.suggestion = "both";
          fileselect.folder.command = [
            "alacritty"
            "-e"
            "ranger"
            "--choosedir={}"
          ];
          fileselect.single_file.command = [
            "alacritty"
            "-e"
            "ranger"
            "--choosefile={}"
          ];
          fileselect.multiple_files.command = [
            "alacritty"
            "-e"
            "ranger"
            "--choosefiles={}"
          ];
          scrolling.smooth = true;
          tabs.last_close = "close";
          #tabs.padding = {
          #"bottom" = 2;
          #"left" = 2;
          #"right" = 2;
          #"top" = 2;
          #};
          tabs.select_on_remove = "last-used";
          colors.webpage.preferred_color_scheme = "dark";
        };

        keyBindings = {
          normal = {
            "<Ctrl-v>" = "spawn mpv {url}";
          };

          prompt = {
            "<Ctrl-y>" = "prompt-yes";
          };
        };

        quickmarks = {
          nixpkgs = "https://github.com/NixOS/nixpkgs";
          awesome-nix = "https://github.com/nix-community/awesome-nix";
          home-manager = "https://github.com/nix-community/home-manager";
          nix-package-versions = "https://lazamar.co.uk/nix-versions";
          hackernews = "https://news.ycombinator.com";
          noogle = "https://noogle.dev";
          # dotfiles = "https://${netlib.domainFor "gitea"}/phil/dotfiles";
        };

        searchEngines = {
          # nix related search engines
          hmo = "https://mipmip.github.io/home-manager-option-search/?query={}";
          nixp = "https://search.nixos.org/packages?channel=unstable&query={}";
          nixo = "https://search.nixos.org/options?channel=unstable&query={}";
          noogle = "https://noogle.dev/?term=%22{}%22";

          # general search
          w = "https://en.wikipedia.org/wiki/Special:Search?search={}&go=Go&ns0=1";
          aw = "https://wiki.archlinux.org/?search={}";
          nw = "https://nixos.wiki/index.php?search={}";
          g = "https://www.google.com/search?hl=en&q={}";
        };
      };
    };
}
