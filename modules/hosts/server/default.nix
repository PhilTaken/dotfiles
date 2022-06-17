{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.server;
  net = import ../../../network.nix { };
in
{
  imports = [
    ./adguardhome.nix
    ./caddy.nix
    ./calibre-web.nix
    ./fail2ban.nix
    ./gitea.nix
    ./grafana.nix
    ./grafana.nix
    ./influxdb2.nix
    ./iperf.nix
    ./jellyfin.nix
    ./keycloak.nix
    ./nextcloud.nix
    ./nginx.nix
    ./openssh.nix
    ./seafile.nix
    ./syncthing.nix
    ./telegraf.nix
    ./ttrss.nix
    ./unbound.nix
    ./vector.nix
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
  };
}
