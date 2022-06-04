{ pkgs
, host
, lib
, ...
}:

with builtins;

let
  nixos = {
    name = "nixos";
    groups = [ "wheel" "video" "audio" "docker" "dialout" "adbusers" "gpio" ];
    shell = pkgs.zsh;
    uid = 1001;
  };
  defaults = [
    "openssh"
    "fail2ban"
    "telegraf"
    "iperf"
  ];
in rec {
  mkServer = { servername
  , services ? []
  , defaultServices ? defaults
  , extraimports ? []
  , fileshare ? {}
  }:
  let
    hardware-config = import (../machines + "/${servername}");
    users = [ nixos ];
    # allows value to overwrite enabled when specified explicitly
    defaultEnabled = builtins.mapAttrs (_: value: lib.mergeAttrs { enable = true; } value);
  in host.mkHost {
    inherit hardware-config users extraimports;

    systemConfig = {
      inherit fileshare;

      wireguard.enable = true;
      nebula.enable = true;

      core.hostName = servername;
      core.docker = false;

      server = {
        enable = true;
        services = foldl' lib.mergeAttrs { } (map
          (service: if builtins.isAttrs service then defaultEnabled service else { "${service}".enable = true; })
          (defaults ++ services));
      };
    };
  };
}
