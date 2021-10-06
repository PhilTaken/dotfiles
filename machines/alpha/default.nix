{ pkgs, ... }:
let
  lib = pkgs.lib;
  ip4_eth0 = "148.251.102.93";
in
rec {

  imports = [ ./hardware-configuration.nix ];

  #boot.loader.grub.device = "/dev/sda";

  # networking
  networking = {
    hostName = "alpha";
    dhcpcd.enable = false;
    usePredictableInterfaceNames = false;
    interfaces.eth0.ipv4.addresses = [{
      address = ip4_eth0;
      prefixLength = 32;
    }];
    defaultGateway = "";
    nameservers = [ "1.1.1.1" ];
    localCommands =
      ''

      ip route add "148.251.69.141" dev "eth0"
      ip route add default via "148.251.69.141" dev "eth0"

    '';
  };
}
