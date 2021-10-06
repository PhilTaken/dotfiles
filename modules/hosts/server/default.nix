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
  };

  config = mkIf (cfg.enable) {
    environment.systemPackages = with pkgs; [ fail2ban ];

    # Enable the OpenSSH daemon.
    services.openssh = {
      enable = true;
      passwordAuthentication = false;
      permitRootLogin = "yes";
      authorizedKeysFiles = [ "/etc/nixos/authorized-keys" ];
    };
  };
}
