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
  options.phil.server = {
    enable = mkOption {
      description = "enable server module";
      type = types.bool;
      default = false;
    };

    sshKeys = mkOption {
      description = "ssh keys for root user";
      type = types.listOf types.str;
      default = [ ];
    };
  };

  config = mkIf (cfg.enable) {
    # fail2ban
    environment.systemPackages = with pkgs; [ fail2ban ];
    services.fail2ban.enable = true;

    # general open ssh config
    services.openssh = {
      enable = true;
      passwordAuthentication = false;
      permitRootLogin = "yes";
      authorizedKeysFiles = [ "/etc/nixos/authorized-keys" ];
    };

    # and set some ssh keys for root
    users.extraUsers.root.openssh.authorizedKeys.keys = cfg.sshKeys;


    # and enable grafana logging TODO
  };
}
