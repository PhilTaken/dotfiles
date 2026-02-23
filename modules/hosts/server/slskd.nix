{
  config,
  lib,
  netlib,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.phil.server.services.slskd;

  web_port = netlib.portFor "slskd-web";
  slsk_port = netlib.portFor "slsk-listen";
in
{
  options.phil.server.services.slskd = {
    enable = mkEnableOption "slskd";
  };

  config = lib.mkMerge [
    (mkIf cfg.enable {
      assertions = [
        {
          assertion = netlib.nodeHasPublicIp;
          message = "the slskd node needs a public ip";
        }
      ];
      sops.secrets.slskd-environmentfile = { };

      services.slskd = {
        enable = true;
        environmentFile = config.sops.secrets.slskd-environmentfile.path;

        # reverse proxy + port forwarding is handled below
        domain = null;
        openFirewall = false;

        settings = {
          flags.force_share_scan = false;
          flags.no_version_check = true;

          web.port = web_port;

          shares.directories = [ "/shared/slskd/share" ];

          directories.incomplete = "/shared/slskd/incomplete";
          directories.downloads = "/shared/slskd/downloads";

          soulseek = {
            listen_ip_address = netlib.thisNode.network_ip.headscale;
            listen_port = slsk_port;
          };
        };
      };

      networking.firewall = {
        allowedUDPPorts = [ slsk_port ];
        allowedTCPPorts = [ slsk_port ];
      };

      phil.fileshare.juicefs.mounts = [ "slskd" ];

      phil.server.services = {
        caddy.proxy = {
          "slskd" = {
            port = web_port;
            public = false;
          };
        };
      };

    })
  ];
}
