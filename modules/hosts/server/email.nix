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
      description = "simple oauth-integrated email server";
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
      default = "stalwart";
    };
  };

  config = let
    hostAddress = "192.0.0.1";
    localAddress = "192.0.0.4";
  in
    mkIf cfg.enable (lib.mkMerge [
      {
        containers.roundcube = {
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
                $config['smtp_host'] = "ssl://%h:465";
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
            ip = net.nodes.${config.networking.hostName}.network_ip.milkyway;

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
                url = "ldaps://ldap.pherzog.xyz";
                base-dn = "ou=users,dc=ldap,dc=pherzog,dc=xyz";
                timeout = "30s";
                tls = {
                  enable = true;
                  allow-invalid-certs = false;
                };

                bind = {
                  dn = "uid=service,ou=users,dc=ldap,dc=pherzog,dc=xyz";
                  secret = "%{file:${config.sops.secrets."ldap-bindauth-pass".path}}%";
                  auth = {
                    enable = true;
                    dn = "uid=?,ou=users,dc=ldap,dc=pherzog,dc=xyz";
                  };
                };

                filter = {
                  name = "(&(|(objectClass=posixAccount)(objectClass=posixGroup))(uid=?))";
                  email = "(&(|(objectClass=posixAccount)(objectClass=posixGroup))(|(mail=?)(mailAlias=?)(mailList=?)))";
                  verify = "(&(|(objectClass=posixAccount)(objectClass=posixGroup))(|(mail=*?*)(mailAlias=*?*)))";
                  expand = "(&(|(objectClass=posixAccount)(objectClass=posixGroup))(mailList=?))";
                  domains = "(&(|(objectClass=posixAccount)(objectClass=posixGroup))(|(mail=*@?)(mailAlias=*@?)))";
                };

                attributes = {
                  name = "uid";
                  class = "inetOrgPerson";
                  description = "givenName";
                  groups = "isMemberOf";
                  email = "mail";
                  email-alias = "mail";

                  # unsure about those
                  secret = "userPassword";
                  quota = "diskQuota";
                };
              };
            };

            tracer."stdout" = {
              type = "stdout";
              level = "info";
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
          143 # imap
          993 # imaps
          25 # smtp
          #   4190 # sieve
        ];

        sops.secrets."dovecot-oauth-config" = {
          owner = config.systemd.services.dovecot2.serviceConfig.User or "root";
          restartUnits = ["dovecot2.service"];
        };

        services.dovecot2 = {
          enable = true;
          enableImap = true;
          enablePAM = false;

          mailUser = "vmail";
          mailGroup = "vmail";

          mailLocation = "maildir:/var/vmail/%d/%n/Maildir";

          mailboxes = {
            Spam = {
              specialUse = "Junk";
              auto = "create";
            };
          };

          extraConfig = ''
            ssl = yes
            ssl_cert = <${config.security.acme.certs."${net.tld}".directory}/fullchain.pem
            ssl_key = <${config.security.acme.certs."${net.tld}".directory}/key.pem

            ssl_min_protocol = TLSv1.2
            ssl_cipher_list = EECDH+AESGCM:EDH+AESGCM
            ssl_prefer_server_ciphers = yes

            mail_plugins = virtual fts fts_lucene

            auth_mechanisms = $auth_mechanisms oauthbearer xoauth2

            passdb {
              driver = oauth2
              mechanisms = oauthbearer xoauth2
              args = ${config.sops.secrets."dovecot-oauth-config".path}
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

            service managesieve-login {
              inet_listener sieve {
                port = 4190
              }
            }
            protocol sieve {
              managesieve_logout_format = bytes ( in=%i : out=%o )
            }
            plugin {
              sieve_dir = /var/vmail/%d/%n/sieve/scripts/
              sieve = /var/vmail/%d/%n/sieve/active-script.sieve
              sieve_extensions = +vacation-seconds
              sieve_vacation_min_period = 1min

              fts = lucene
              fts_lucene = whitespace_chars=@.
            }

            # If you have Dovecot v2.2.8+ you may get a significant performance improvement with fetch-headers:
            imapc_features = $imapc_features fetch-headers
            # Read multiple mails in parallel, improves performance
            mail_prefetch_count = 20
          '';
          modules = [pkgs.dovecot_pigeonhole];
          protocols = ["sieve"];
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
        };

        # TODO set up postfix
        # https://search.nixos.org/options?channel=24.05&from=0&size=50&sort=relevance&type=packages&query=services.postfix
        # services.postfix = {};
      })
    ]);
}
