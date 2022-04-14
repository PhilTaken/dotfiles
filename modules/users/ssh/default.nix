{ pgks
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.ssh;
in
{

  options.phil.ssh = {
    enable = mkOption {
      description = "Enable the ssh module";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    programs.ssh = {
      enable = true;
      matchBlocks = {
        "jureca" = {
          hostname = "jureca.fz-juelich.de";
          user = "herzog1";
          forwardAgent = true;
          #forwardX11 = true;
        };
        "judac" = {
          hostname = "judac.fz-juelich.de";
          user = "herzog1";
          forwardAgent = true;
          #forwardX11 = true;
        };
        "work-pc" = {
          hostname = "iek8680.iek.kfa-juelich.de";
          user = "p.herzog";
          forwardAgent = true;
          forwardX11 = true;
        };
        "vulkan" = {
          hostname = "iek8691.iek.kfa-juelich.de";
          user = "p.herzog";
          forwardX11 = true;
          forwardAgent = true;
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
        "mcserver" = {
          hostname = "192.168.192.42";
          user = "non-admin";
        };
        "router" = {
          hostname = "router.lan";
          user = "root";
        };
        "raspi" = {
          hostname = "192.168.0.120";
          user = "nixos";
        };
        "alpha" = {
          hostname = "148.251.102.93";
          user = "nixos";
          forwardAgent = true;
        };
        "alpha-root" = {
          hostname = "148.251.102.93";
          user = "root";
          forwardAgent = true;
        };
        "zpi" = {
          hostname = "134.94.149.163";
          user = "ubuntu";
          forwardAgent = true;
        };
        "zpi2" = {
          hostname = "134.94.149.164";
          user = "ubuntu";
          forwardAgent = true;
        };
      };
    };
  };
}
