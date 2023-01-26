_:

rec {
  tld = "pherzog.xyz";

  networks = rec {
    endpoints = {
      "alpha" = "148.251.102.93";
    };

    default = milkyway;

    # due to how nebula works with certificates, changing these will not actually change
    # the hosts ips, just name resolution for hosted services
    milkyway = {
      interfaceName = "milkyway";
      gateway = "10.200.0.0/24";

      alpha = "10.200.0.1";
      beta = "10.200.0.2";
      gamma = "10.200.0.3";
      #nixos-laptop = "10.200.0.4";
      delta = "10.200.0.5";
      epsilon = "10.200.0.6";
    };

    # these can be adjusted however you desire
    # fallback network -> no p2p
    yggdrasil = {
      interfaceName = "yggdrasil";
      gateway = "10.100.0.0/24";

      alpha = "10.100.0.1";
      beta = "10.100.0.2";
      gamma = "10.100.0.3";
      #nixos-laptop = "10.100.0.4";
      delta = "10.100.0.5";
      epsilon = "10.100.0.6";
    };
  };

  servers = builtins.attrNames services;
  services = {
    # vm on a hetzner server, debian host
    alpha = [
      "influxdb2"
      "grafana"
    ];

    # raspberry pi @ home
    #beta = [ ];

    # mini nas @ home
    delta = [
      "unbound"
      "homer"

      "hound"

      "gitea"
      "jellyfin"
      "syncthing"
      "nextcloud"
      "calibre"

      "nix-serve"

      "navidrome"
    ];
  };
}
