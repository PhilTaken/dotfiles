{
  lib,
  config,
  ...
}: let
  cfg = config.phil.server.services.gleamdication;
in {
  options.phil.server.services.gleamdication = {
    enable = lib.mkEnableOption "gleamdication";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8000;
    };
    host = lib.mkOption {
      type = lib.types.str;
      default = "gleamdication";
    };
  };

  config = lib.mkIf cfg.enable {
    services.gleamdication = {inherit (cfg) enable port;};

    phil.server.services.caddy.proxy."${cfg.host}" = {
      inherit (cfg) port;
      public = false;
    };
  };
}
