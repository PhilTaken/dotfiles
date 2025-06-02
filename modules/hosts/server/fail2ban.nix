{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.phil.server.services.fail2ban;
in {
  options.phil.server.services.fail2ban = {
    enable = (mkEnableOption "fail2ban ssh login blocker") // {default = true;};
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      fail2ban
    ];

    services.fail2ban = {
      enable = true;
      ignoreIP =
        ["127.0.0.0/8" "::1"]
        ++ [
          config.phil.network.networks.headscale.netmask
          config.phil.network.networks.milkyway.netmask
          config.phil.network.networks.yggdrasil.netmask
          config.phil.network.networks.lan.netmask
        ];
    };
  };
}
