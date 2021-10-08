{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.gpg;
in
{
  options.phil.gpg = {
    enable = mkOption {
      description = "enable gpg module";
      type = types.bool;
      default = false;
    };

    gpgKey = mkOption {
      description = "default gpg key";
      type = types.nullOr types.str;
      default = null;
    };

    sshKeys = mkOption {
      description = "User's ssh keys for gpg-agent";
      type = types.listOf types.str;
      default = [ ];
    };
  };

  config = mkIf (cfg.enable) {
    programs.gpg = {
      enable = true;
      settings.default-key = mkIf (cfg.gpgKey != null) cfg.gpgKey;
    };

    services.gpg-agent = mkIf (cfg.sshKeys != [ ]) {
      enable = true;
      enableSshSupport = true;
      sshKeys = cfg.sshKeys;
    };
  };
}

