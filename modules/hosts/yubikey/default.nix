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

    debug = mkOption {
      description = "enable debugging for the pam module";
      type = types.bool;
      default = false;
    };

    chalRespPath = mkOption {
      description = "path to the response files";
      type = types.str;
      default = "/etc/yubipam";
    };
  };

  config = mkIf (cfg.enable) {
    sops.secrets.nixos-ykchal.path = "${cfg.chalRespPath}/nixos-14321676";
    sops.secrets.maelstroem-ykchal.path = "${cfg.chalRespPath}/maelstroem-14321676";

    services.udev.packages = with pkgs; [ yubikey-personalization ];

    security.pam.yubico = {
      enable = true;
      debug = cfg.debug;
      mode = "challenge-response";
      challengeResponsePath = cfg.chalRespPath;
    };
  };
}
