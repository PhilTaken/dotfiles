{ pkgs
, config
, lib
, net
, ...
}:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.phil.server;
in
{
  imports = [
    ./adguardhome.nix
    ./caddy
    ./calibre-web.nix
    ./fail2ban.nix
    ./gitea.nix
    ./grafana.nix
    ./grafana.nix
    ./homer.nix
    ./hound.nix
    ./influxdb2.nix
    ./iperf.nix
    ./jellyfin.nix
    ./keycloak.nix
    ./navidrome.nix
    ./nextcloud.nix
    ./nginx.nix
    ./nix-serve.nix
    ./openssh.nix
    ./seafile.nix
    ./syncthing.nix
    ./telegraf.nix
    ./ttrss.nix
    ./unbound.nix
    ./vector.nix
  ];

  options.phil.server.enable = mkEnableOption "server module";

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      nmap
      hdparm
      htop
      bottom
      usbutils
    ];
  };
}
