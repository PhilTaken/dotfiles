{
  pkgs,
  config,
  netlib,
  lib,
  ...
}:
let
  cfg = config.phil.fileshare.garage;
in
{
  options.phil.fileshare.garage = {
    enable = lib.mkEnableOption "garage";

    data_dir = lib.mkOption {
      description = "data dir for the garage volume";
      type = lib.types.str;
    };

    data_capacity = lib.mkOption {
      description = "maximum size of the data dir";
      type = lib.types.str;
      default = "2T";
    };

    metadata_dir = lib.mkOption {
      description = "metadata dir for the garage volume";
      type = lib.types.str;
      default = "/var/lib/garage/meta";
    };
  };

  config =
    let
      rpc_port = netlib.portFor "garage-rpc";
      s3_port = netlib.portFor "garage-s3";
      s3_web_port = netlib.portFor "garage-s3-web";
      k2v_port = netlib.portFor "garage-k2v";
      admin_port = netlib.portFor "garage-admin";

      s3_domain = netlib.domainFor ".garage";
      s3_web_domain = netlib.domainFor ".web.garage";
    in
    lib.mkIf cfg.enable {
      sops.secrets.garage-environmentfile = { };

      services.garage = {
        enable = true;
        package = pkgs.garage_2;
        environmentFile = config.sops.secrets.garage-environmentfile.path;
        settings = {
          data_dir = [
            {
              capacity = cfg.data_capacity;
              path = cfg.data_dir;
            }
          ];

          metadata_dir = cfg.metadata_dir;

          db_engine = "sqlite";

          replication_factor = 1;

          rpc_bind_addr = "[::]:${builtins.toString rpc_port}";
          rpc_public_addr = "127.0.0.1:${builtins.toString rpc_port}";

          k2v_api.api_bind_addr = "[::]:${builtins.toString k2v_port}";
          admin.api_bind_addr = "[::]:${builtins.toString admin_port}";

          s3_api = {
            s3_region = "garage";
            api_bind_addr = "[::]:${builtins.toString s3_port}";
            root_domain = s3_domain;
          };

          s3_web = {
            bind_addr = "[::]:${builtins.toString s3_web_port}";
            root_domain = s3_web_domain;
            index = "index.html";
          };
        };
      };

      phil.server.services.caddy.proxy = {
        "rpc.garage".port = rpc_port;
        "garage".port = s3_port;
        "web.garage".port = s3_web_port;
        "*.s3".port = s3_port;
        "*.s3web".port = s3_web_port;
      };
    };
}
