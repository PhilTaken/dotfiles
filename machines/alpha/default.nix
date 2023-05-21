{...}: let
  ip4_eth0 = "148.251.102.93";
  gateway_ip = "148.251.69.141";
in {
  imports = [./hardware-configuration.nix];

  # networking
  networking = {
    hostName = "alpha";
    dhcpcd.enable = false;
    usePredictableInterfaceNames = false;
    interfaces = {
      eth0.ipv4 = {
        addresses = [
          {
            address = ip4_eth0;
            prefixLength = 32;
          }
        ];
        routes = [
          {
            address = gateway_ip;
            prefixLength = 32;
          }
        ];
      };
      #"yggdrasil".mtu = 1280;
    };
    defaultGateway = {
      interface = "eth0";
      address = gateway_ip;
    };
    nameservers = ["1.1.1.1"];
  };

  boot.loader = {
    grub.enable = true;
    grub.device = "/dev/sda";
  };

  system.stateVersion = "21.05";
}
