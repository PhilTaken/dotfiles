{lib, ...}: {
  config.phil.network = {
    tld = "pherzog.xyz";

    networks = {
      headscale.netmask = "100.64.0.0/24";
      headscale.ifname = "tailscale0";

      milkyway.netmask = "10.200.0.0/24";
      milkyway.ifname = "milkyway";

      yggdrasil.netmask = "10.100.0.0/24";
      yggdrasil.ifname = "tun0";

      lan.netmask = "192.168.178.0/16";
      lan.ifname = "eth0";
    };

    nodes = {
      beta = {
        system = "aarch64-linux";
        public_ip = "195.201.93.72";
        network_ip."headscale" = "100.64.0.25";
        network_ip."milkyway" = "10.200.0.2";
        network_ip."yggdrasil" = "10.100.0.2";
        services = [
          "keycloak"

          # email requires kanidm,
          # TODO fix
          # "kanidm"
          "email"

          # npm error [esbuild] Failed to find package "@esbuild/linux-arm64" on the file system
          #"immich"

          "grafana"
          "freshrss"
          "headscale"
          "bookstack"
        ];
      };

      delta = {
        system = "x86_64-linux";
        network_ip."headscale" = "100.64.0.26";
        network_ip."milkyway" = "10.200.0.5";
        network_ip."yggdrasil" = "10.100.0.5";
        network_ip."lan" = "192.168.178.26";
        services = [
          "gitea"

          # keep these on delta to use at home
          "arrs"
          "jellyfin"
          "homeassistant"
          "unbound"
          "nextcloud"

          "mealie"

          "paperless"

          "audiobookshelf"
        ];
      };
    };
  };

  options.phil.network = let
    inherit (lib) types;

    networkType = types.submodule ({name, ...}: {
      options = {
        name = lib.mkOption {
          type = types.str;
          default = name;
          description = "the name of the network. defaults to the attribute name";
        };

        # TODO check if valid netmask
        netmask = lib.mkOption {
          type = types.str;
          description = "the network's netmask";
        };

        ifname = lib.mkOption {
          type = types.str;
          description = "the network's interface name";
        };
      };
    });

    nodeType = types.submodule ({name, ...}: {
      options = {
        name = lib.mkOption {
          type = types.str;
          default = name;
        };

        system = lib.mkOption {
          type = types.enum ["aarch64-linux" "aarch64-darwin" "x86_64-linux"];
          description = "the nodes system architecture";
        };

        sshUser = lib.mkOption {
          type = types.str;
          default = "nixos";
        };

        services = lib.mkOption {
          # TODO types.enum of the available services?
          type = types.listOf (types.str);
          description = "services running on this node";
        };

        # TODO check that every node has at most one ip for every network (cfg.networks)
        # TODO check if valid ip + fits in netmask
        network_ip = lib.mkOption {
          type = types.attrsOf types.str;
          description = "network -> ip mapping for this node";
        };

        public_ip = lib.mkOption {
          type = types.nullOr types.str;
          description = "the nodes public ip";
          default = null;
        };
      };
    });
  in {
    tld = lib.mkOption {
      type = types.str;
      description = "top level domain";
    };

    networks = lib.mkOption {
      type = types.attrsOf networkType;
    };

    nodes = lib.mkOption {
      description = "nodes in the network";
      type = types.attrsOf nodeType;
    };
  };
}
