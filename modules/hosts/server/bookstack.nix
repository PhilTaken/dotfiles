{
  config,
  lib,
  netlib,
  ...
}: let
  inherit (lib) mkOption mkIf types mkEnableOption;
  cfg = config.phil.server.services.bookstack;
  net = config.phil.network;
in {
  options.phil.server.services.bookstack = {
    enable = mkEnableOption "bookstack";
    host = mkOption {
      description = "bookstack domain";
      type = types.str;
      default = "bookstack";
    };

    port = mkOption {
      type = types.port;
      default = netlib.portFor "bookstack";
    };
  };

  config = let
    hostAddress = "192.0.1.1";
    localAddress = "192.0.1.2";
  in
    mkIf cfg.enable {
      sops.secrets.bookstack-appkeyfile.mode = "777";
      sops.secrets.bookstack-oidc-secret.mode = "777";

      networking.nat = {
        enable = true;
        internalInterfaces = ["ve-+"];
        externalInterface = "enp1s0";
      };

      # configure the proxy
      phil.server.services = {
        caddy.proxy."${cfg.host}" = {
          inherit (cfg) port;
          ip = net.nodes.${config.networking.hostName}.network_ip.headscale;
        };
        homer.apps."${cfg.host}" = {
          show = true;
          settings = {
            name = "Bookstack";
            subtitle = "Notes + More";
            tag = "app";
            keywords = "selfhosted notes";
            logo = "https://en.wikipedia.org/wiki/File:BookStack_logo.svg";
          };
        };
      };

      containers.bookstack = let
        appKeyFile = config.sops.secrets.bookstack-appkeyfile.path;
        oidcClientSecret = config.sops.secrets.bookstack-oidc-secret.path;
      in {
        ephemeral = false;
        autoStart = true;

        privateNetwork = true;
        inherit localAddress hostAddress;

        forwardPorts = [
          {
            containerPort = 80;
            hostPort = cfg.port;
            protocol = "tcp";
          }
        ];

        # TODO bind mount for data dir for backups
        bindMounts = {
          ${oidcClientSecret} = {
            hostPath = oidcClientSecret;
            isReadOnly = true;
          };
          ${appKeyFile} = {
            hostPath = appKeyFile;
            isReadOnly = true;
          };
        };

        config = {
          config,
          pkgs,
          ...
        }: {
          # https://github.com/NixOS/nixpkgs/issues/162686
          networking.nameservers = ["1.1.1.1"];
          # WORKAROUND
          environment.etc."resolv.conf".text = "nameserver 1.1.1.1";
          networking.firewall.enable = false;

          services.bookstack = rec {
            enable = true;
            hostname = netlib.domainFor cfg.host;
            inherit appKeyFile;
            appURL = "https://${hostname}";

            config = {
              AUTH_METHOD = "oidc";
              AUTH_AUTO_INITIATE = false;
              OIDC_NAME = "KeyCloak";
              OIDC_END_SESSION_ENDPOINT = true;
              OIDC_ISSUER_DISCOVER = true;

              # set up oidc details
              OIDC_ISSUER = "https://${netlib.domainFor "keycloak"}/realms/services";
              OIDC_DISPLAY_NAME_CLAIMS = "name";
              OIDC_CLIENT_ID = "bookstack";
              OIDC_CLIENT_SECRET._secret = oidcClientSecret;

              # map roles to groups
              OIDC_USER_TO_GROUPS = true;
              OIDC_GROUPS_CLAIM = "groups";
              OIDC_REMOVE_FROM_GROUPS = true;

              # enable this for debugging
              # OIDC_DUMP_USER_DETAILS = true;
            };

            database.createLocally = true;
          };

          system.stateVersion = "24.05";
        };
      };
    };
}
