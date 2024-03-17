_: rec {
  tld = "pherzog.xyz";

  endpoints = {
    "alpha" = "148.251.102.93";
  };

  networks = rec {
    # due to how nebula works with certificates, changing these will not actually change
    # the hosts ips, just name resolution for hosted services
    default = milkyway;

    milkyway = {
      interfaceName = "milkyway";
      netmask = "10.200.0.0/24";

      hosts = {
        alpha = "10.200.0.1";
        beta = "10.200.0.2";
        gamma = "10.200.0.3";
        #nixos-laptop = "10.200.0.4";
        delta = "10.200.0.5";
        epsilon = "10.200.0.6";
      };
    };

    yggdrasil = {
      interfaceName = "yggdrasil";
      netmask = "10.100.0.0/24";

      hosts = {
        alpha = "10.100.0.1";
        beta = "10.100.0.2";
        gamma = "10.100.0.3";
        #nixos-laptop = "10.100.0.4";
        delta = "10.100.0.5";
        epsilon = "10.100.0.6";
      };
    };

    lan = {
      interfaceName = "lan";
      netmask = "192.168.178.0/16";

      hosts = {
        delta = "192.168.178.26";
      };
    };
  };

  servers = builtins.attrNames services;

  services = {
    # vm on a hetzner server, debian host
    alpha = [
      "grafana"
    ];

    # raspberry pi @ home
    #beta = [ ];

    # mini nas @ home
    delta = [
      # "syncthing"
      # "keycloak"
      # "grocy"
      # "writefreely"
      # "ldap"
      # "hound"

      "arrs"
      "calibre"
      "gitea"
      "homeassistant"
      "homer"
      "jellyfin"
      "navidrome"
      "nextcloud"
      "nix-serve"
      "unbound"
    ];
  };
}
