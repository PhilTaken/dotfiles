{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.mullvad;
in
{
  options.phil.mullvad = {
    enable = mkEnableOption "enable the mullvad service";
    enable-old = mkEnableOption "enable the mullvad vpn (frankfurt)";
    enable-new = mkEnableOption "enable the mullvad vpn (duesseldorf)";
  };

  # TODO: multiple mullvad locations
  config = {
    # mullvad vpn definition for de-frankfurt and de-duesseldorf
    sops.secrets.mullvad-privateKey = mkIf (cfg.enable-old) { };
    sops.secrets.mullvad-privateKey-new = mkIf (cfg.enable-new) { };

    environment.systemPackages = with pkgs; mkIf (cfg.enable) [
      mullvad-vpn
    ];

    # just use this, the others dont work for some reason
    # TODO: figure out why
    services.mullvad-vpn.enable = cfg.enable;

    networking.wg-quick.interfaces = {
      mlvd-de22 = mkIf (cfg.enable-old) {
        address = [ "10.69.90.26/32" "fc00:bbbb:bbbb:bb01::6:5a19/128" ];
        dns = [ "193.138.218.74" ];
        privateKeyFile = config.sops.secrets.mullvad-privateKey.path;
        peers = [
          {
            publicKey = "vtqDtifokiHna0eBshGdJLedj/lzGW+iDvWKx+YjDFs=";
            allowedIPs = [ "0.0.0.0/0" "::0/0" ];
            endpoint = "193.27.14.98:51820";
          }
        ];
      };
      mlvd-de20 = mkIf (cfg.enable-new) {
        address = [ "10.67.54.255/32" "fc00:bbbb:bbbb:bb01::4:36fe/128" ];
        dns = [ "100.64.0.3" ];
        privateKeyFile = config.sops.secrets.mullvad-privateKey-new.path;
        peers = [
          {
            publicKey = "/pS3lXg1jTJ7I58GD/s/4GNL2B0U8JNbjbH9Ddh0myw=";
            allowedIPs = [ "0.0.0.0/0" "::0/0" ];
            endpoint = "185.254.75.3:51820";
          }
        ];
      };
    };
  };
}
