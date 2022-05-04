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
    ./keycloak.nix
    ./nginx.nix
    ./unbound.nix
    ./calibre-web.nix
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
          53
          #80    # to get certs (let's encrypt)
          #443   # ---- " ----
        ];

        allowedUDPPorts = [
          53
        ];
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
          53   # dns (unbound)
          5353 # dns
          80   # http
          443  # https

          8086 # influxdb2

          1900  # jellyfin
          7359  # jellyfin
        ];

        allowedTCPPorts = [
          53 # dns (unbound)
          80 # webinterfaces (reverse proxy)
          443 # webinterfaces ssl (reverse proxy)
          31111 # adguard home webinterface

          8086 # influxdb2

          8096 # jellyfin
          8920 # jellyfin
        ];
      };
    };
  };
}
