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
      default = true;
    };

    gpgKey = mkOption {
      description = "default gpg key";
      type = types.nullOr types.str;
      default = "BDCD0C4E9F252898";
    };

    sshKeys = mkOption {
      description = "User's ssh keys for gpg-agent";
      type = types.listOf types.str;
      default = [ "F40506C8F342CC9DF1CC8E9C50DD4037D2F6594B" ];
    };
  };

  config = mkIf cfg.enable {
    programs.gpg = {
      enable = true;
      settings.default-key = mkIf (cfg.gpgKey != null) cfg.gpgKey;
    };

    services.gpg-agent = mkIf (cfg.sshKeys != [ ]) {
      enable = true;
      enableSshSupport = true;
      inherit (cfg) sshKeys;
    };
  };
}

