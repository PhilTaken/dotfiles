{ pkgs
, host
, lib
, ...
}:

with builtins;

let
  defaults = [
    "openssh"
    "fail2ban"
    "telegraf"
    "vector"
    "iperf"
  ];

  users = [{
    name = "nixos";
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "docker"
      "dialout"
      "adbusers"
      "gpio"
      # only temporary for testing makemkv
      "cdrom"
    ];
    shell = pkgs.zsh;
  }];

  # allows value to overwrite enabled when specified explicitly
  defaultEnabled = builtins.mapAttrs (_: value: lib.mergeAttrs { enable = true; } value);
in
rec {
  mkServer =
    { servername
    , services ? [ ]
    , defaultServices ? defaults
    , extraimports ? [ ]
    , fileshare ? { }
    }:
    let
      hardware-config = import (../machines + "/${servername}");
    in
    host.mkHost {
      inherit hardware-config users;

      extraimports = extraimports ++ [{
        documentation.enable = false;
        environment.noXlibs = true;
        i18n.supportedLocales = lib.mkForce [ "en_US.UTF-8/UTF-8" ];
      }];

      systemConfig = {
        inherit fileshare;

        wireguard.enable = true;
        nebula.enable = true;

        core.hostName = servername;
        core.docker = false;

        sound.enable = false;
        video.enable = false;
        yubikey.enable = false;

        server = {
          enable = true;
          services = foldl' lib.mergeAttrs { } (map
            (service: if builtins.isAttrs service then defaultEnabled service else { "${service}".enable = true; })
            (defaults ++ services));
        };
      };
    };
}
