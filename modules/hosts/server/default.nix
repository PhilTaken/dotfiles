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
    ./caddy.nix
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
        allowedTCPPorts = [ ];
        allowedUDPPorts = [ ];
      };

      "tailscale0" = {
        allowedTCPPorts = [ ];
        allowedUDPPorts = [ ];
      };

      "yggdrasil" = {
        allowedUDPPorts = [
          53   # dns (unbound)
          80   # http (caddy)
          443  # https (caddy)
        ];

        allowedTCPPorts = [
          53 # dns (unbound)
          80 # webinterfaces (caddy)
          443 # webinterfaces ssl (caddy)
        ];
      };
    };
  };
}
