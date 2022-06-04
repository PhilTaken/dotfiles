{ ... }:

{
  endpoints = {
    "alpha" = "148.251.102.93";
  };

  networks = rec {
    default = milkyway;

    # due to how nebula works with certificates, changing these will not actually change
    # the hosts ips, just name resolution for hosted services
    milkyway = {
      gateway = "10.200.0.0/24";

      alpha = "10.200.0.1";
      beta = "10.200.0.2";
      gamma = "10.200.0.3";
      delta = "10.200.0.4";
      nixos-laptop = "10.200.0.5";
    };

    # these can be adjusted however you desire
    yggdrasil = {
      gateway = "10.100.0.0/24";

      alpha = "10.100.0.1";
      beta = "10.100.0.2";
      gamma = "10.100.0.3";
      nixos-laptop = "10.100.0.4";
      delta = "10.100.0.5";
    };
  };
}
