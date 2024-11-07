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
    ./audiobookshelf.nix
    ./bookstack.nix
    ./caddy
    ./calibre-web.nix
    ./email.nix
    ./fail2ban.nix
    ./freshrss.nix
    ./gitea.nix
    ./gleamdication.nix
    ./grafana.nix
    ./grafana.nix
    ./grocy.nix
    ./headscale.nix
    ./homeassistant
    ./homer.nix
    ./hound.nix
    ./immich.nix
    ./influxdb2.nix
    ./iperf.nix
    ./jellyfin.nix
    ./kanidm.nix
    ./keycloak.nix
    ./ldap.nix
    ./mealie.nix
    ./navidrome.nix
    ./nextcloud.nix
    ./nginx.nix
    ./nix-serve.nix
    ./openssh.nix
    ./paperless.nix
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
      bottom
      duf
      fclones
      fd
      hdparm
      htop
      iotop
      jq
      lnav
      nmap
      smartmontools
      tree
      usbutils
    ];

    # not available on aarch64-linux
    #programs.sysdig.enable = true;
  };
}
