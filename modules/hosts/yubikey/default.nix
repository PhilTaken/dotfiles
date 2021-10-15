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
    services.udev.packages = with pkgs; [ yubikey-personalization ];

    security.pam.yubico = {
      enable = true;
      debug = cfg.debug;
      mode = "challenge-response";
      challengeResponsePath = cfg.chalRespPath;
    };

    #environment.etc = {
      #"yubipam/nixos-14321676".target = config.sops.secrets.nixos-ykchal.path;
      #"yubipam/maelstroem-14321676".target = config.sops.secrets.maelstroem-ykchal.path;
    #};
  };
}
