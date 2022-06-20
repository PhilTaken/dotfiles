{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.yubikey;
  contains = val: builtins.foldl' (accum: elem: elem == val || accum) false;
in
{
  options.phil.yubikey = {
    enable = mkOption {
      description = "enable yubikey module";
      type = types.bool;
      default = true;
    };

    debug = mkOption {
      description = "enable debugging for the pam module";
      type = types.bool;
      default = false;
    };

    users = mkOption {
      description = "users to give acces to the yubkikey secret to";
      type = types.nullOr types.str;
      default = null;
    };

    chalRespPath = mkOption {
      description = "path to the response files";
      type = types.str;
      default = "/etc/yubipam";
    };
  };

  config = mkIf (cfg.enable) {
    sops.secrets.nixos-ykchal = mkIf (contains "nixos" (builtins.attrNames config.users.users)) {
      owner = "nixos";
      path = "${cfg.chalRespPath}/nixos-14321676";
    };

    sops.secrets.maelstroem-ykchal = mkIf (contains "maelstroem" (builtins.attrNames config.users.users)) {
      owner = "maelstroem";
      path = "${cfg.chalRespPath}/maelstroem-14321676";
    };

    services.udev.packages = with pkgs; [ yubikey-personalization ];

    security.pam.yubico = {
      enable = true;
      debug = cfg.debug;
      mode = "challenge-response";
      challengeResponsePath = cfg.chalRespPath;
    };
  };
}
