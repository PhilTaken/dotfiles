{
  config,
  lib,
  pkgs,
  netlib,
  ...
}: let
  inherit (lib) mkOption mkIf types mkEnableOption;
  cfg = config.phil.server.services.email;
  net = config.phil.network;
in {
  options.phil.server.services.email = {
    enable = mkEnableOption "email server";
    url = mkOption {
      description = "simple email server";
      type = types.str;
      default = netlib.domainFor cfg.host;
    };

    host = mkOption {
      type = types.str;
      default = "mail";
    };

    port = mkOption {
      type = types.port;
      default = netlib.portFor "rondcube";
      description = "internal port for the roundcube webinterface";
    };

    jmap-port = mkOption {
      type = types.port;
      default = netlib.portFor "stalwart-jmap";
      description = "port for the stalwart http jmap/admin interface";
    };

    server_type = mkOption {
      type = types.enum ["postfix-dovecot" "stalwart"];
      default = "postfix-dovecot";
    };
  };

  config = let
    hostAddress = "192.0.0.1";
    localAddress = "192.0.0.4";
  in
    mkIf cfg.enable (lib.mkMerge [
      {
        containers.roundcube = lib.mkIf false {
          ephemeral = false;
          autoStart = true;

          #privateNetwork = false;
          privateNetwork = true;
          inherit localAddress hostAddress;

          forwardPorts = [
            {
              containerPort = 80;
              hostPort = cfg.port;
              protocol = "tcp";
            }
          ];

          config = {
            config,
            pkgs,
            ...
          }: {
            # https://github.com/NixOS/nixpkgs/issues/162686
            networking.nameservers = ["1.1.1.1"];
            # WORKAROUND
            environment.etc."resolv.conf".text = "nameserver 1.1.1.1";

            networking.firewall.enable = false;

            services.nginx.virtualHosts.${net.tld} = {
              forceSSL = false;
              enableACME = false;
            };

            services.roundcube = {
              enable = true;
              hostName = net.tld;
              extraConfig = ''
                $config['use_https'] = true;
                $config['auto_create_user'] = true;
                $config['imap_host'] = "ssl://mail.pherzog.xyz:993";

                $config['mail_domain'] = '%t';
                $config['smtp_host'] = "ssl://mail.pherzog.xyz:465";
                $config['smtp_user'] = "%u";
                $config['smtp_pass'] = "%p";
              '';
            };
          };
        };
        networking.nat = {
          enable = true;
          internalInterfaces = ["ve-+"];
          externalInterface = "enp1s0";
        };

        phil.server.services = {
          caddy.proxy."${cfg.host}" = {
            inherit (cfg) port;
            ip = net.nodes.${config.networking.hostName}.network_ip.headscale;

            # make public?
            public = false;
          };
          homer.apps."${cfg.host}" = {
            show = true;
            settings = {
              name = "Roundcube";
              subtitle = "Email Frontend";
              tag = "app";
              keywords = "selfhosted cloud email";
              logo = "https://roundcube.net/images/roundcube_logo_icon.svg";
            };
          };
        };
      }

      (lib.mkIf (cfg.server_type
        == "stalwart") {
        assertions = [
          {
            assertion = netlib.nodeHasPublicIp;
            message = "the email node needs a public ip to function properly";
          }
        ];

        phil.server.services = {
          caddy.proxy."mailadmin" = {
            port = cfg.jmap-port;
            public = false;
          };
          caddy.proxy."jmap" = {
            port = cfg.jmap-port;
            public = true;
          };
        };

        sops.secrets."stalwart-admin-secret" = {
          owner = "stalwart-mail";
          restartUnits = ["stalwart-mail.service"];
        };

        sops.secrets."ldap-bindauth-pass" = {
          owner = "stalwart-mail";
          restartUnits = ["stalwart-mail.service"];
        };

        sops.secrets."dkim-privatekey" = {
          owner = "stalwart-mail";
          restartUnits = ["stalwart-mail.service"];
        };

        sops.secrets."dkim-privatekey-rsa" = {
          owner = "stalwart-mail";
          restartUnits = ["stalwart-mail.service"];
        };

        users.users."stalwart-mail".extraGroups = ["nginx"];

        services.stalwart-mail = {
          enable = true;
          openFirewall = true;

          settings = {
            lookup.default.hostname = cfg.url;
            server = {
              listener."smtp" = {
                bind = ["[::]:25"];
                protocol = "smtp";
                tls.implicit = false;
              };

              listener."management" = {
                bind = ["127.0.0.1:${builtins.toString cfg.jmap-port}"];
                protocol = "http";
              };

              listener."submissions" = {
                bind = ["[::]:465"];
                protocol = "smtp";
                tls.implicit = true;
              };

              listener."imaptls" = {
                bind = ["[::]:993"];
                protocol = "imap";
                tls.implicit = true;
              };

              tls = {
                enable = true;
                implicit = true;
                timeout = "1m";
                disable-protocols = ["TLSv1.2"];
                disable-ciphers = ["TLS13_AES_256_GCM_SHA384" "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256"];
                ignore-client-order = true;
              };
            };

            auth.dkim = {
              sign = [
                {
                  "if" = "listener != 'smtp'";
                  "then" = "['ed25519', 'rsa']";
                }
                {"else" = false;}
              ];
            };

            report.analysis = {
              addresses = ["dmarc@*" "abuse@*"];
              forward = false;
              store = "30d";
            };

            signature = {
              "ed25519" = {
                private-key = "%{file:${config.sops.secrets."dkim-privatekey".path}}%";
                domain = "pherzog.xyz";
                selector = "default";
                headers = ["From" "To" "Date" "Subject" "Message-ID"];
                algorithm = "ed25519-sha256";
                canonicalization = "simple/simple";
                set-body-length = true;
                # TODO enable this and analyze
                report = false;
              };

              "rsa" = {
                private-key = "%{file:${config.sops.secrets."dkim-privatekey-rsa".path}}%";
                domain = "pherzog.xyz";
                selector = "rsa_default";
                headers = ["From" "To" "Date" "Subject" "Message-ID"];
                algorithm = "rsa-sha256";
                canonicalization = "relaxed/relaxed";
                expire = "10d";
                set-body-length = false;
                # TODO enable this and analyze
                report = false;
              };
            };

            authentication = {
              fallback-admin = {
                user = "admin";
                secret = "%{file:${config.sops.secrets."stalwart-admin-secret".path}}%";
              };

              master = {
                user = "master";
                secret = "%{file:${config.sops.secrets."stalwart-admin-secret".path}}%";
              };
            };

            storage = {
              data = "rocksdb";
              fts = "rocksdb";
              blob = "rocksdb";
              lookup = "rocksdb";
              directory = "ldap";
            };

            store."rocksdb" = {
              type = "rocksdb";
              path = "/var/lib/stalwart-mail/data";
              compression = "lz4";
            };

            directory = {
              "internal" = {
                type = "internal";
                store = "rocksdb";
              };

              "ldap" = {
                type = "ldap";
                url = "ldaps://kanidm.pherzog.xyz";
                base-dn = "dc=kanidm,dc=pherzog,dc=xyz";
                timeout = "30s";
                tls = {
                  enable = true;
                  allow-invalid-certs = false;
                };

                bind = {
                  dn = "dn=token";
                  secret = "%{file:${config.sops.secrets."ldap-bindauth-pass".path}}%";
                };

                filter = {
                  name = "(&(|(objectclass=posixaccount)(objectclass=posixgroup))(name=?))";
                  email = "(&(|(objectclass=posixaccount)(objectclass=posixgroup))(|(mail;primary=?)(mail;alternative=?)))";
                  verify = "(&(|(objectclass=posixaccount)(objectclass=posixgroup))(|(mail;primary=*?*)(mail;alternative=*?*)))";
                  expand = "(&(|(objectclass=posixaccount)(objectclass=posixgroup))(maillist=?))";
                  domains = "(&(|(objectclass=posixaccount)(objectclass=posixgroup))(|(mail=*@?)(mailalias=*@?)))";
                };

                attributes = {
                  name = "name";
                  class = "class";
                  description = "displayname";
                  groups = "memberof";
                  email = "emailprimary";
                  email-alias = "emailalternative";

                  # unsure about those
                  secret = "userPassword";
                  quota = "diskQuota";
                };
              };
            };

            tracer."stdout" = {
              type = "stdout";
              level = "trace";
              ansi = false;
              enable = true;
            };

            certificate.default = {
              cert = "%{file:${config.security.acme.certs."${net.tld}".directory}/cert.pem}%";
              private-key = "%{file:${config.security.acme.certs."${net.tld}".directory}/key.pem}%";
              default = true;
              subjects = ["mail.pherzog.xyz" "pherzog.xyz"];
            };
          };
        };
      })

      (lib.mkIf (cfg.server_type
        == "postfix-dovecot") {
        assertions = [
          {
            assertion = netlib.nodeHasPublicIp;
            message = "the email node needs a public ip to function properly";
          }
        ];

        networking.firewall.allowedTCPPorts = [
          25 # smtp
          465 # smtps
          587 # submission
          143 # imap
          993 # imaps
        ];

        sops.secrets."dovecot-ldap-config" = {
          owner = config.systemd.services.dovecot2.serviceConfig.User or "root";
          restartUnits = ["dovecot2.service"];
        };

        systemd.services."dovecot2" = lib.mkIf config.phil.server.services.kanidm.enable {
          after = ["kanidm.service"];
          requires = ["kanidm.service"];
        };

        services.dovecot2 = {
          enable = true;
          enableImap = true;
          enableLmtp = true;
          enablePAM = false;

          mailLocation = "maildir:/var/vmail/%d/%n/Maildir";
          mailUser = "vmail";
          mailGroup = "vmail";

          mailPlugins = {
            globally.enable = ["virtual" "fts" "fts_lucene"];
          };

          extraConfig = ''
            ssl = yes
            ssl_cert = <${config.security.acme.certs."${net.tld}".directory}/fullchain.pem
            ssl_key = <${config.security.acme.certs."${net.tld}".directory}/key.pem

            ssl_min_protocol = TLSv1.2
            ssl_cipher_list = EECDH+AESGCM:EDH+AESGCM
            ssl_prefer_server_ciphers = yes
            ssl_dh=<${config.security.dhparams.params.dovecot2.path}

            auth_default_realm = ${net.tld}
            service auth {
              unix_listener auth-userdb {
                mode = 0640
                user = vmail
                group = vmail
              }
              # Postfix smtp-auth
              unix_listener /var/lib/postfix/queue/private/auth {
                mode = 0666
                user = postfix
                group = postfix
              }
            }

            passdb {
              driver = ldap
              args = ${config.sops.secrets."dovecot-ldap-config".path}
            }

            userdb {
              driver = ldap
              args = ${config.sops.secrets."dovecot-ldap-config".path}
            }

            service lmtp {
              user = vmail
              unix_listener /var/lib/postfix/queue/private/dovecot-lmtp {
                group = postfix
                mode = 0600
                user = postfix
              }
            }

            service doveadm {
              inet_listener {
                port = 4170
                ssl = yes
              }
            }

            service imap-login {
              client_limit = 1000
              service_count = 0
              inet_listener imaps {
                port = 993
              }
            }

            # If you have Dovecot v2.2.8+ you may get a significant performance improvement with fetch-headers:
            imapc_features = $imapc_features fetch-headers
            # Read multiple mails in parallel, improves performance
            mail_prefetch_count = 20
          '';

          pluginSettings = {
            fts = "lucene";
            fts_lucene = "whitespace_chars=@.";
          };
        };

        users.users.vmail = {
          home = "/var/vmail";
          createHome = true;
          isSystemUser = true;
          uid = 1005;
          shell = "/run/current-system/sw/bin/nologin";
        };

        security.dhparams = {
          enable = true;
          params.dovecot2 = {};
          params.postfix512.bits = 512;
          params.postfix2048.bits = 1024;
        };

        services.postfix = {
          enable = true;
          enableSubmission = true;
          enableSubmissions = true;
          hostname = "mail.pherzog.xyz";
          domain = "pherzog.xyz";
          networks = ["127.0.0.0/8" "localhost"];

          masterConfig = {
            submission = {
              type = "inet";
              private = false;
              command = "smtpd";
              args = [
                "-o smtpd_client_restrictions=permit_sasl_authenticated,reject"
                "-o syslog_name=postfix/smtps"
                "-o smtpd_tls_wrappermode=yes"
                "-o smtpd_sasl_auth_enable=yes"
                "-o smtpd_tls_security_level=none"
                "-o smtpd_reject_unlisted_recipient=no"
                "-o smtpd_recipient_restrictions="
                "-o smtpd_relay_restrictions=permit_sasl_authenticated,reject"
                "-o milter_macro_daemon_name=ORIGINATING"
              ];
            };
          };

          config = {
            smtp_bind_address = netlib.thisNode.public_ip;

            mailbox_transport = "lmtp:unix:private/dovecot-lmtp";

            virtual_mailbox_domains = "$mydomain";
            virtual_transport = "lmtp:unix:private/dovecot-lmtp";

            # bigger attachement size
            mailbox_size_limit = "202400000";
            message_size_limit = "51200000";

            smtpd_banner = "$myhostname ESMTP";
            disable_vrfy_command = "yes";
            smtpd_helo_required = "yes";
            smtpd_delay_reject = "yes";
            strict_rfc821_envelopes = "yes";

            # send Limit
            smtpd_error_sleep_time = "1s";
            smtpd_soft_error_limit = "10";
            smtpd_hard_error_limit = "20";

            smtpd_tls_cert_file = "${config.security.acme.certs."${net.tld}".directory}/full.pem";
            smtpd_tls_key_file = "${config.security.acme.certs."${net.tld}".directory}/key.pem";
            smtpd_tls_CAfile = "${config.security.acme.certs."${net.tld}".directory}/fullchain.pem";

            smtpd_tls_dh512_param_file = config.security.dhparams.params.postfix512.path;
            smtpd_tls_dh1024_param_file = config.security.dhparams.params.postfix2048.path;

            smtpd_tls_session_cache_database = ''btree:''${data_directory}/smtpd_scache'';
            smtpd_tls_mandatory_protocols = "!SSLv2,!SSLv3,!TLSv1,!TLSv1.1";
            smtpd_tls_protocols = "!SSLv2,!SSLv3,!TLSv1,!TLSv1.1";
            smtpd_tls_mandatory_ciphers = "medium";
            tls_medium_cipherlist = "AES128+EECDH:AES128+EDH";

            # authentication
            smtpd_sasl_type = "dovecot";
            smtpd_sasl_path = "/var/lib/postfix/queue/private/auth";
            smtpd_sasl_auth_enable = "yes";
            smtpd_sasl_security_options = "noanonymous";
            smtpd_sasl_tls_security_options = "$smtpd_sasl_security_options";

            # tls
            smtp_tls_note_starttls_offer = "yes";
            smtp_tls_security_level = "dane";
            smtpd_use_tls = "yes";
            smtpd_tls_security_level = "may";
            smtpd_tls_auth_only = "yes";
            smtpd_tls_ciphers = "high";

            smtpd_recipient_restrictions = "permit_mynetworks,
                               permit_sasl_authenticated,
                               reject_non_fqdn_sender,
                               reject_non_fqdn_recipient,
                               reject_non_fqdn_hostname,
                               reject_invalid_hostname,
                               reject_unknown_sender_domain,
                               reject_unknown_recipient_domain,
                               reject_unknown_client_hostname,
                               reject_unauth_pipelining,
                               reject_unknown_client,
                               permit";

            smtpd_relay_restrictions = "permit_mynetworks, permit_sasl_authenticated, defer_unauth_destination";
            smtpd_client_restrictions = "permit_mynetworks, permit_sasl_authenticated, reject_invalid_hostname, reject_unknown_client, permit";
            smtpd_helo_restrictions = "permit_mynetworks, permit_sasl_authenticated, reject_unauth_pipelining, reject_non_fqdn_hostname, reject_invalid_hostname, warn_if_reject reject_unknown_hostname, permit";
            smtpd_sender_restrictions = "permit_mynetworks, permit_sasl_authenticated, reject_non_fqdn_sender, reject_unknown_sender_domain, reject_unknown_client_hostname, reject_unknown_address";
            smtpd_etrn_restrictions = "permit_mynetworks, reject";
            smtpd_data_restrictions = "reject_unauth_pipelining, reject_multi_recipient_bounce, permit";

            milter_default_action = "accept";
            milter_protocol = "6";
            smtpd_milters = "unix:/run/opendkim/opendkim.sock";
            non_smtpd_milters = "unix:/run/opendkim/opendkim.sock";
          };
        };

        # opendkim
        sops.secrets."dkim-privatekey" = {
          owner = config.services.postfix.user;
          restartUnits = ["opendkim.service"];
          path = "/run/lib/opendkim-keys/${config.services.opendkim.selector}.private";
        };

        services.opendkim = {
          enable = true;
          domains = "pherzog.xyz";
          selector = "default";
          user = config.services.postfix.user;
          group = config.services.postfix.group;

          keyPath = "/run/opendkim-keys";
        };
      })
    ]);
}
