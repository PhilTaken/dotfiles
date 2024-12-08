{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption mkIf types mkEnableOption;
  cfg = config.phil.server.services.arrs;

  sonarr_port = 8989;
  radarr_port = 7878;
  #prowlarr_port = 9696;
  lidarr_port = 8686;
  bazarr_port = 6767;
  jackett_port = 9117;
in {
  options.phil.server.services.arrs = {
    enable = mkEnableOption "arrs";
    media_folder = mkOption {
      type = types.str;
      default = "/media/Video";
      description = "Root folder for media";
    };
  };

  config = mkIf cfg.enable {
    users.groups.media = {};

    programs.fuse.userAllowOther = true;

    systemd.tmpfiles.rules = [
      "Z ${cfg.media_folder} 0770 - media -"
    ];

    phil.server.services = {
      homer.apps = {
        "sonarr" = {
          show = true;
          settings = {
            name = "Sonarr";
            subtitle = "Smart PVR for newsgroup and bittorrent users.";
            tag = "app";
            keywords = "selfhosted media";
            logo = "https://sonarr.tv/img/logo.png";
          };
        };
        "radarr" = {
          show = true;
          settings = {
            name = "Radarr";
            subtitle = "Movie organizer/manager for usenet and torrent users.";
            tag = "app";
            keywords = "selfhosted media";
            logo = "https://radarr.video/img/logo.png";
          };
        };
        #"prowlarr" = {
        #show = true;
        #settings = {
        #name = "Prowlarr";
        #subtitle = "The Ultimate Indexer Manager";
        #tag = "app";
        #keywords = "selfhosted media";
        #logo = "https://prowlarr.com/logo/32.png";
        #};
        #};
        "lidarr" = {
          show = true;
          settings = {
            name = "Lidarr";
            subtitle = "Looks and smells like Sonarr but made for music.";
            tag = "app";
            keywords = "selfhosted media";
            logo = "https://lidarr.audio/img/logo.png";
          };
        };
        "bazarr" = {
          show = true;
          settings = {
            name = "Bazarr";
            subtitle = "A companion application to Sonarr and Radarr";
            tag = "app";
            keywords = "selfhosted media";
            logo = "https://www.bazarr.media/assets/img/logo.png";
          };
        };

        "jackett" = {
          show = true;
          settings = {
            name = "Jackett";
            subtitle = "API Support for your favorite torrent trackers";
            tag = "app";
            keywords = "selfhosted media";
          };
        };
      };
      caddy.proxy = {
        "sonarr" = {
          port = sonarr_port;
        };
        "radarr" = {
          port = radarr_port;
        };
        #"prowlarr" = {
        #port = prowlarr_port;
        #};
        "lidarr" = {
          port = lidarr_port;
        };
        "bazarr" = {
          port = bazarr_port;
        };
        "jackett" = {
          port = jackett_port;
        };
      };
    };

    # TODO remove at some point (tm)
    nixpkgs.config.permittedInsecurePackages = [
      "aspnetcore-runtime-6.0.36"
      "aspnetcore-runtime-wrapped-6.0.36"
      "dotnet-sdk-6.0.428"
      "dotnet-sdk-wrapped-6.0.428"
    ];

    services = {
      sonarr = {
        enable = true;
        group = "media";
      };

      radarr = {
        enable = true;
        group = "media";
      };

      #prowlarr = {
      #enable = true;
      #group = "media";
      #};

      lidarr = {
        enable = true;
        group = "media";
      };

      jackett = {
        enable = true;
        group = "media";
      };

      bazarr = {
        enable = true;
        group = "media";
      };
    };
  };
}
