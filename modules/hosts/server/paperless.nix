{
  config,
  lib,
  netlib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption mkIf types mkEnableOption;
  cfg = config.phil.server.services.paperless;
in {
  options.phil.server.services.paperless = {
    enable = mkEnableOption "paperless";
    url = mkOption {
      description = "paperless url (webinterface)";
      type = types.str;
      default = netlib.domainFor cfg.host;
    };

    port = mkOption {
      description = "paperless port (webinterface)";
      type = types.port;
      default = netlib.portFor "paperless";
    };

    host = mkOption {
      type = types.str;
      default = "paperless";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets."paperless-password".owner = config.services.paperless.user;
    sops.secrets."paperless-oauth-secret".owner = config.services.paperless.user;

    services.paperless = {
      enable = true;
      # limit to internal ip on delta?
      address = "0.0.0.0";
      inherit (cfg) port;

      passwordFile = config.sops.secrets."paperless-password".path;

      consumptionDirIsPublic = true;
      settings = {
        PAPERLESS_CONSUMER_IGNORE_PATTERN = [
          ".DS_STORE/*"
          "desktop.ini"
        ];
        PAPERLESS_OCR_LANGUAGE = "deu+eng";
        PAPERLESS_OCR_USER_ARGS = {
          optimize = 1;
          pdfa_image_compression = "lossless";
          continue_on_soft_render_error = true;
        };

        # virtiofsd doesn't send inotify events (not sure if generally, or because we
        # mount the same host share on another vm (samba) and modify it there).
        PAPERLESS_CONSUMER_POLLING = 1; # seconds
        # Wait three seconds between file-modified checks. After 5 consecutive checks
        # where the file wasn't modified it will be consumed.
        PAPERLESS_CONSUMER_POLLING_DELAY = 3;

        PAPERLESS_CONSUMER_ENABLE_BARCODES = true;
        PAPERLESS_CONSUMER_ENABLE_ASN_BARCODE = true;
        PAPERLESS_CONSUMER_BARCODE_SCANNER = "ZXING";
        PAPERLESS_CONSUMER_RECURSIVE = true;
        PAPERLESS_FILENAME_FORMAT = "{owner_username}/{created_year}-{created_month}-{created_day}_{asn}_{title}";

        # Nginx does that better.
        PAPERLESS_ENABLE_COMPRESSION = false;
        PAPERLESS_NUMBER_OF_SUGGESTED_DATES = 8;
        PAPERLESS_TASK_WORKERS = 4;
        PAPERLESS_WEBSERVER_WORKERS = 4;

        # oauth
        PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";
        PAPERLESS_SOCIALACCOUNT_PROVIDERS = builtins.toJSON {
          openid_connect.APPS = [
            {
              provider_id = "keycloak";
              name = "Keycloak";
              client_id = "paperless";
              # added further down
              #secret = "";
              settings.server_url = "https://${netlib.domainFor "keycloak"}/realms/services/.well-known/openid-configuration";
            }
          ];
        };
      };
    };

    # Add secret to PAPERLESS_SOCIALACCOUNT_PROVIDERS
    systemd.services.paperless-web.script = lib.mkBefore ''
      oidcSecret=$(< ${config.sops.secrets.paperless-oauth-secret.path})
      export PAPERLESS_SOCIALACCOUNT_PROVIDERS=$(
        ${pkgs.jq}/bin/jq <<< "$PAPERLESS_SOCIALACCOUNT_PROVIDERS" \
          --compact-output \
          --arg oidcSecret "$oidcSecret" '.openid_connect.APPS.[0].secret = $oidcSecret'
      )
    '';

    phil.server.services.caddy.proxy."${cfg.host}" = {
      inherit (cfg) port;
      public = false;
    };
  };
}
