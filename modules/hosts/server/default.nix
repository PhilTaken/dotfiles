{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.phil.server;
in {
  imports = [
    ./adguardhome.nix
    ./arrs.nix
    ./caddy
    ./calibre-web.nix
    ./fail2ban.nix
    ./freshrss.nix
    ./gitea.nix
    ./grafana.nix
    ./grafana.nix
    ./grocy.nix
    ./homeassistant
    ./homer.nix
    ./hound.nix
    ./influxdb2.nix
    ./iperf.nix
    ./jellyfin.nix
    ./keycloak.nix
    ./ldap.nix
    ./navidrome.nix
    ./nextcloud.nix
    ./nginx.nix
    ./nix-serve.nix
    ./openssh.nix
    ./prometheus/prometheus-exporter.nix
    ./seafile.nix
    ./syncthing.nix
    ./telegraf.nix
    ./ttrss.nix
    ./unbound.nix
    ./vector.nix
    ./writefreely.nix
  ];

  options.phil.server.enable = mkEnableOption "server module";

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      nmap
      hdparm
      htop
      bottom
      usbutils
      iotop
      tree
      duf
      jq
      smartmontools
      fd
      fclones
    ];

    # not available on aarch64-linux
    #programs.sysdig.enable = true;
  };
}
