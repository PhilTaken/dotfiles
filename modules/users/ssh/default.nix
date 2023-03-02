{ pgks
, config
, lib
, ...
}:
let
  cfg = config.phil.ssh;
  inherit (lib) mkEnableOption mkIf;
in
{

  options.phil.ssh = {
    enable = mkEnableOption "ssh";
  };

  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      matchBlocks = {
        # home
        "router" = {
          hostname = "router.lan";
          user = "root";
        };
        "betalocal" = {
          hostname = "192.168.0.120";
          user = "nixos";
        };
        "deltalocal" = {
          hostname = "192.168.0.21";
          user = "nixos";
        };

        # yggdrasil
        "alpha" = {
          hostname = "10.200.0.1";
          user = "nixos";
        };
        "beta" = {
          hostname = "10.200.0.2";
          user = "nixos";
        };
        "delta" = {
          hostname = "10.200.0.5";
          user = "nixos";
        };

        "epsilon" = {
          hostname = "10.200.0.4";
          user = "maelstroem";
        };


        # remote vps
        "vps2" = {
          hostname = "185.212.44.199";
          user = "nixos";
        };
        "alphadirect" = {
          hostname = "148.251.102.93";
          user = "nixos";
        };
        "alpha-root" = {
          hostname = "148.251.102.93";
          user = "root";
        };
      };
    };
  };
}
