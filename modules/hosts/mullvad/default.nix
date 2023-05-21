{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.phil.mullvad;
in {
  options.phil.mullvad = {
    enable = mkEnableOption "enable the mullvad vpn";
    interfaceName = mkOption {
      type = types.str;
      default = "mlvd0";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.mullvad-privateKey = {};

    networking.wireguard.interfaces = {
      ${cfg.interfaceName} = {
        ips = ["10.68.36.230/32" "fc00:bbbb:bbbb:bb01::5:24e5/128"];
        #dns = [ "10.64.0.1" ];
        privateKeyFile = config.sops.secrets.mullvad-privateKey.path;

        allowedIPsAsRoutes = false;

        peers = [
          {
            publicKey = "veGD6/aEY6sMfN3Ls7YWPmNgu3AheO7nQqsFT47YSws=";
            allowedIPs = ["0.0.0.0/0" "::0/0"];
            endpoint = "185.213.154.69:51820";
          }
        ];
      };
    };
  };
}
