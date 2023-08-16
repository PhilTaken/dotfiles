{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types mkIf;
  cfg = config.phil.gpg;
in {
  options.phil.gpg = {
    enable = mkEnableOption "gpg";

    gpgKey = mkOption {
      description = "default gpg key";
      type = types.nullOr types.str;
      default = "BDCD0C4E9F252898";
    };

    sshKeys = mkOption {
      description = "User's ssh keys for gpg-agent";
      type = types.listOf types.str;
      default = ["F40506C8F342CC9DF1CC8E9C50DD4037D2F6594B"];
    };
  };

  config = mkIf cfg.enable {
    programs.gpg = {
      enable = true;
      settings.default-key = mkIf (cfg.gpgKey != null) cfg.gpgKey;
      homedir = "${config.xdg.dataHome}/gnupg";
      publicKeys = [
        {
          source = ./pubkey.txt;
          trust = 5;
        }
      ];
    };

    services.gpg-agent = mkIf (cfg.sshKeys != [] && lib.hasInfix "linux" pkgs.system) {
      enable = true;
      enableSshSupport = true;
      inherit (cfg) sshKeys;
    };
  };
}
