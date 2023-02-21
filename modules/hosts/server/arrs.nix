{ pkgs
, config
, lib
, ...
}:

let
  inherit (lib) mkOption mkIf types mkEnableOption;
  cfg = config.phil.server.services.arrs;
in
{
  options.phil.server.services.arrs = {
    enable = mkEnableOption "arrs";
    host = mkOption {
      type = types.str;
      default = "arrs";
    };
  };

  config = mkIf cfg.enable {
    phil.mullvad.enable = lib.mkForce true;

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

    phil.server.services = {
      caddy.proxy = {
        "${cfg.host}" = { inherit (cfg) port; };
      };

      containers.arrs = {
        interfaces = [ "mlvd" "milkyway" ];

        ephemeral = false;
        autoStart = true;

        privateNetwork = true;
        inherit localAddress hostAddress;

        config = { config, pkgs, ... }: {
          # https://github.com/NixOS/nixpkgs/issues/162686
          #networking.nameservers = [ "1.1.1.1" ];
          # WORKAROUND
          #environment.etc."resolv.conf".text = "nameserver 1.1.1.1";
          networking.firewall.enable = false;
          networking.interfaces = {
            mlvd = {
              ipv4.routes = [{ address = "0.0.0.0"; prefixLength = "0"; }];
            };
          };

          services = {
            sonarr = {
              enable = true;
            };

            radarr = {
              enable = true;
            };

            prowlarr = {
              enable = true;
            };

            lidarr = {
              enable = true;
            };

            bazarr = {
              enable = true;
            };
          };

          system.stateVersion = "22.11";
        };
      };
    };
  };
}
