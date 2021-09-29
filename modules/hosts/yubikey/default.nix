{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.yubikey;
in
{
  options.phil.yubikey = {
    enable = mkOption {
      description = "enable yubikey module";
      type = types.bool;
      default = false;
    };

    yubifile = mkOption {
      description = "chalresp file for yubikey authentication";
      type = types.nullOr types.path;
      default = null;
    };

    # TODO get username from core module?
    username = mkOption {
      description = "main users username";
      type = types.str;
      default = "nixos";
    };

    debug = mkOption {
      description = "enable debugging for the pam module";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    services.udev.packages = with pkgs; [ yubikey-personalization ];

    security.pam.yubico = {
      enable = cfg.debug;
      #debug = true;
      mode = "challenge-response";
      challengeResponsePath = "/etc/yubipam/";
    };
  };

  environment.etc = mkIf (cfg.yubifile != null) {
    "yubipam/${cfg.username}-14321676".source = cfg.yubifile;
  };
}
