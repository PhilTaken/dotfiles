{ pgks
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.ssh;
  net = import ../../../network.nix;

  extraHosts = net.networks.default;
in
{

  options.phil.ssh = {
    enable = mkOption {
      description = "Enable the ssh module";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf (cfg.enable) {
    programs.ssh = {
      enable = true;
      matchBlocks = rec {
        # work
        "jureca" = {
          hostname = "jureca.fz-juelich.de";
          user = "herzog1";
        };
        "jurecat" = {
          inherit (jureca) hostname user;
          extraOptions = {
            "RequestTTY" = "yes";
            "RemoteCommand" = "tmux attach || tmux new";
          };
        };
        "judac" = {
          hostname = "judac.fz-juelich.de";
          user = "herzog1";
        };
        "vulkan" = {
          hostname = "iek8691.iek.kfa-juelich.de";
          user = "p.herzog";
          forwardX11 = true;
        };
        "juceda" = {
          hostname = "icg2019.icg.kfa-juelich.de";
          user = "herzog";
          extraOptions = {
            "HostkeyAlgorithms" = "+ssh-rsa";
            "PubkeyAcceptedAlgorithms" = "+ssh-rsa";
            "ServerAliveInterval" = "20";
            "TCPKeepAlive" = "no";
          };
        };

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
