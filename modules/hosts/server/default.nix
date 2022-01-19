{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.server;
in
{
  imports = [
    ./fail2ban.nix
    ./openssh.nix
    ./jellyfin.nix
    ./grafana.nix
    ./ttrss.nix
    ./adguardhome.nix
    ./iperf.nix
    ./telegraf.nix
    ./influxdb2.nix
    ./syncthing.nix
  ];

  options.phil.server.enable = mkEnableOption "server module";

  config = mkIf (cfg.enable) {
    environment.systemPackages = with pkgs; [
      hdparm
      htop
      usbutils
    ];

    # firewall
    networking.firewall.interfaces = {
      "eth0" = {
        allowedTCPPorts = [
          #80    # to get certs (let's encrypt)
          #443   # ---- " ----
        ];

        allowedUDPPorts = [ ];
      };

      "tailscale0" = {
        allowedTCPPorts = [
          53 # dns (adguard home)
          31111 # adguard home webinterface
        ];

        allowedUDPPorts = [
          53 # dns (adguard home)
          51820
        ];
      };

      "yggdrasil" = {
        allowedUDPPorts = [
          5353 # dns
          #cfg.services.influxdb2.port
        ];

        allowedTCPPorts = [
          53 # dns (adguard home)
          80 # tt-rss webinterface
          443 # tt-rss ssl
          31111 # adguard home webinterface
          #cfg.services.influxdb2.port
        ];
      };
    };
  };
}
