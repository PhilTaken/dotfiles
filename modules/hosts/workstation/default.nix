{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.workstation;
in
{
  options.phil.workstation = {
    enable = mkOption {
      description = "enable workstation module";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    # serokell binary cache secrets
    sops.secrets = {
      aws-credentials = {
        sopsFile = ../../../sops + "/serokell.yaml";
        #path = "/root/.aws/credentials";
        mode = "600";
        owner = (config.users.users."maelstroem" or config.users.users."nixos").name;
      };
    };

    environment.systemPackages = with pkgs; [
      vlc
      calibre
      foliate
      pdfsam-basic
      xournalpp
      baobab
      xfce.thunar

      webcord
      obsidian
    ];
  };
}

