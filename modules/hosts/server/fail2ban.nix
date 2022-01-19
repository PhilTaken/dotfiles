{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.server.services.fail2ban;
in
{

  options.phil.server.services.fail2ban = {
    enable = mkEnableOption "fail2ban ssh login blocker";
  };

  config = mkIf (cfg.enable) {
    environment.systemPackages = with pkgs; [
      fail2ban
    ];

    services.fail2ban.enable = true;
  };
}
