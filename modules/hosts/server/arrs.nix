{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption mkIf types mkEnableOption;
  cfg = config.phil.server.services.arrs;
in {
  options.phil.server.services.arrs = {
    enable = mkEnableOption "arrs";
    host = mkOption {
      type = types.str;
      default = "sonarr";
    };
  };

  config = mkIf cfg.enable {
    phil.mullvad.enable = lib.mkForce true;
    phil.mullvad.interfaceName = "mlvd1";

    phil.server.services = {
      homer.apps = {
        "sonarr" = {
          show = true;
          settings = {
            name = "Sonarr";
            subtitle = "multimedia pvr";
            tag = "app";
            keywords = "selfhosted";
            logo = "https://sonarr.tv/img/logo.png";
          };
        };
      };
      caddy.proxy = {
        "sonarr" = {
          port = 555;
        };
      };
    };

    containers.arrs = {
      ephemeral = false;
      autoStart = true;

      #interfaces = [ config.phil.mullvad.interfaceName ];

      privateNetwork = true;
      hostAddress = "192.0.1.1";
      localAddress = "192.0.1.2";

      config = {
        config,
        pkgs,
        ...
      }: {
        # https://github.com/NixOS/nixpkgs/issues/162686
        #networking.nameservers = [ "1.1.1.1" ];
        # WORKAROUND
        #environment.etc."resolv.conf".text = "nameserver 1.1.1.1";
        #networking.firewall.enable = false;
        #networking.interfaces = {
        #mlvd = {
        #ipv4.routes = [{ address = "0.0.0.0"; prefixLength = "0"; }];
        #};
        #};

        services = {
          #sonarr = {
          #enable = true;
          #};

          #radarr = {
          #enable = true;
          #};

          #prowlarr = {
          #enable = true;
          #};

          #lidarr = {
          #enable = true;
          #};

          #bazarr = {
          #enable = true;
          #};
        };

        system.stateVersion = "22.11";
      };
    };
  };
}
