{
  host,
  inputs,
  ...
}:
with builtins; let
  defaults = [
    "openssh"
    "fail2ban"
    #"telegraf"
    #"vector"
    "iperf"
  ];

  users = [
    {
      name = "nixos";
      extraGroups = [
        "wheel"
        "video"
        "audio"
        "docker"
        "dialout"
        "gpio"
        # only temporary for testing makemkv
        "cdrom"
      ];
      shell = pkgs.zsh;
    }
  ];

  # allows value to overwrite enabled when specified explicitly
  defaultEnabled = builtins.mapAttrs (_: lib.mergeAttrs {enable = true;});

  inherit (inputs.nixpkgs) lib;
in {
  mkServer = {
    servername,
    services ? [],
    defaultServices ? defaults,
    extraimports ? [],
    fileshare ? {},
  }:
    host.mkHost {
      inherit users;

      extraimports =
        extraimports
        ++ [
          {
            documentation.enable = false;
            environment.noXlibs = true;
          }
        ];

      extraHostModules = [
        {
          options.stylix = lib.mkOption {
            description = "placeholder module";
            type = lib.types.anything;
            default = null;
          };
        }
      ];

      systemConfig = {
        inherit fileshare;

        wireguard.enable = true;
        nebula.enable = true;

        core.hostName = servername;
        #core.docker = false;

        sound.enable = false;
        video.enable = false;
        yubikey.enable = false;

        server = {
          enable = true;
          services = foldl' lib.mergeAttrs {} (map
            (service:
              if builtins.isAttrs service
              then defaultEnabled service
              else {"${service}".enable = true;})
            (defaults ++ services));
        };
      };
    };
}
