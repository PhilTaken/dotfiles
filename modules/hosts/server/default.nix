{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.server;
  net = import ../../../network.nix {};
in {
  imports = [
    ./adguardhome.nix
    ./caddy.nix
    ./calibre-web.nix
    ./fail2ban.nix
    ./grafana.nix
    ./influxdb2.nix
    ./iperf.nix
    ./jellyfin.nix
    ./keycloak.nix
    ./seafile.nix
    ./nginx.nix
    ./openssh.nix
    ./syncthing.nix
    ./telegraf.nix
    ./ttrss.nix
    ./unbound.nix
  ];

  options.phil.server.enable = mkEnableOption "server module";

  config = mkIf (cfg.enable) {
    environment.systemPackages = with pkgs; [
      nmap
      hdparm
      htop
      bottom
      usbutils
    ];

    # firewall
    networking.firewall.interfaces = {
      "eth0" = {
        allowedTCPPorts = [ ];
        allowedUDPPorts = [ ];
      };

      "tailscale0" = {
        allowedTCPPorts = [ ];
        allowedUDPPorts = [ ];
      };

      "${net.networks.default.interfaceName}" = {
        allowedUDPPorts = [
          53   # dns (unbound)
          80   # http (caddy)
          443  # https (caddy)

          8086
        ];

        allowedTCPPorts = [
          53 # dns (unbound)
          80 # webinterfaces (caddy)
          443 # webinterfaces ssl (caddy)

          8086
        ];
      };
    };
  };
}
