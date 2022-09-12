{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.server.services.adguardhome;
in
{

  options.phil.server.services.adguardhome = {
    enable = mkEnableOption "adguard home dns ad blocker";
    url = mkOption {
      description = "adguardhome url (webinterface)";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    services.adguardhome = {
      enable = true;
      host = "http://127.0.0.1";
      port = 31111;
      openFirewall = false;
    };
  };
}
