{ pkgs
, config
, lib
, ...
}:

let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.phil.mullvad;
in
{
  options.phil.mullvad = {
    enable = mkEnableOption "enable the mullvad vpn";
    interfaceName = mkOption {
      type = types.str;
      default = "mlvd";
    };

    enableInterface = mkEnableOption "enable the mullvad vpn interface";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.mullvad-vpn ];
    services.mullvad-vpn.enable = true;

    sops.secrets.mullvad-privateKey = {};

    networking.wg-quick.interfaces = mkIf cfg.enableInterface {
      ${cfg.interfaceName} = {
        address = [ "10.64.52.43/32" "fc00:bbbb:bbbb:bb01::1:342a/128" ];
        dns = [ "10.64.0.1" ];
        privateKeyFile = config.sops.secrets.mullvad-privateKey.path;

        peers = [{
          publicKey = "W+iNU2J6P0LRdW7SkRZdj3atH0y7o/TgKvF8I/wRDHM=";
          allowedIPs = [ ];
          endpoint = "185.254.75.3:51820";
        }];
      };
    };
  };
}
