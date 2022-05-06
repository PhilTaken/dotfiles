# SSH fix: `export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)`
{
  # todo:
  # - clone rassword store into home dir
  inputs = {
    # unstable > stable
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    #nixpkgs.url = "github:nixos/nixpkgs/master";

    # NUR
    nur-src = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # local user package managment
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # deploy remote setups
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # devshell for some nice menu + easy command adding capabilities
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # for secret managment
    sops-nix-src = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly = {
      url = "github:neovim/neovim?dir=contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify = {
      url = "github:PhilTaken/spicetify-nix";
      #url = "/home/nixos/Documents/gits/spicetify-nix";
    };

    polymc.url = "github:PolyMC/PolyMC";
  };
  outputs =
    { self
    , nixpkgs
    , home-manager
    , deploy-rs
    , nur-src
    , devshell
    , nixos-hardware
    , sops-nix-src
    , neovim-nightly
    , spicetify
    , polymc
    , ...
    }@inputs:
    let
      inherit (nixpkgs) lib;
      system = "x86_64-linux";

      overlays = [
        nur-src.overlay
        (import ./custom_pkgs)
        (import ./overlays/gopass-rofi.nix { inherit inputs; })
        (import ./overlays/rofi-overlay.nix { inherit inputs; })
        devshell.overlay
        sops-nix-src.overlay
        deploy-rs.overlay
        #neovim-nightly.overlay
        polymc.overlay
        (final: super: {
          makeModulesClosure = x:
            super.makeModulesClosure (x // { allowMissing = true; });
        })
      ];

      nixpkgsFor = system:
        import nixpkgs {
          inherit system overlays;
          config.allowUnfree = true;
        };

      libFor = system:
        import ./lib rec {
          inherit home-manager lib overlays system;
          pkgs = nixpkgsFor system;
          extramodules = [
            sops-nix-src.nixosModules.sops
          ];
          extraHMImports = [
            spicetify.homeManagerModule
          ];
        };

      systemUsersFor = pkgs: {
        nixos = {
          name = "nixos";
          groups = [ "wheel" "video" "audio" "docker" "dialout" "adbusers" ];
          shell = pkgs.zsh;
          uid = 1001;
        };

        maelstroem = {
          name = "maelstroem";
          groups = [ "wheel" "video" "audio" "docker" "dialout" "cdrom" ];
          shell = pkgs.zsh;
          uid = 1000;
        };
      };

      util = libFor "x86_64-linux";
      raspiUtil = libFor "aarch64-linux";

      aarch64_pkgs = nixpkgsFor "aarch64-linux";
      pkgs = nixpkgsFor "x86_64-linux";

      raspiUsers = systemUsersFor aarch64_pkgs;
      systemUsers = systemUsersFor pkgs;
    in
    {
      #devShells."${system}".default = util.shells.legacyShell;
      devShells."${system}".default = util.shells.devShell;

      # older version for backwards compatibility
      devShell."${system}" = util.shells.devShell;

      overlays.default = (import ./custom_pkgs);

      homeManagerConfigurations =
        let
          gpgKey = "BDCD0C4E9F252898";
          sshKey = "F40506C8F342CC9DF1CC8E9C50DD4037D2F6594B";
        in
        {
          nixos = util.user.mkHMUser {
            username = "nixos";

            userConfig = {
              sway.enable = true;
              firefox.enable = true;
              music = {
                enable = true;
                enableMpris = true;
              };
              git = {
                enable = true;
                userName = "Philipp Herzog";
                userEmail = "philipp.herzog@protonmail.com";
                signKey = gpgKey;
              };
              mail.enable = true;
              neovim.enable = true;
              ssh.enable = true;
              zsh_full.enable = true;
              gpg = {
                inherit gpgKey;
                enable = true;
                sshKeys = [ sshKey ];
              };
            };
            extraPackages = pkgs: with pkgs; [
              calibre
              kicad

              gnome3.adwaita-icon-theme
              xournalpp
            ];
          };

          maelstroem = util.user.mkHMUser {
            username = "maelstroem";

            userConfig = {
              firefox.enable = true;
              music.enable = true;
              #kde.enable = true;
              gnome.enable = true;
              git = {
                enable = true;
                userName = "Philipp Herzog";
                userEmail = "philipp.herzog@protonmail.com";
                signKey = gpgKey;
              };
              mail.enable = true;
              neovim.enable = true;
              ssh.enable = true;
              zsh_full.enable = true;
              gpg = {
                inherit gpgKey;
                enable = true;
                sshKeys = [ sshKey ];
              };
            };

            extraPackages = pkgs: with pkgs; [
              nur.repos.shados.tmm
            ];
          };
        };

        nixosConfigurations = let
          # include in the imports to build an iso image for the respective systems (TODO: check if it works)
          baseInstallerImport = "${nixpkgs}/nixos/modules/installer/cd-dvd/iso-image.nix";
          raspInstallerImport = "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix";
        in {
        # vm on a hetzner server, debian host (10.100.0.1)
        alpha =
          let
            hardware-config = import (./machines/alpha);
            users = with systemUsers; [ nixos ];
          in
          util.host.mkHost {
            inherit hardware-config users;

            systemConfig = {
              core = {
                docker = false;
                hostName = "alpha";
                bootLoader = "grub";
                grubDevice = "/dev/sda";
              };

              server = {
                enable = true;
                services = {
                  caddy.proxy = {
                    "influx" = 8086;
                  };

                  #keycloak.enable = true;

                  openssh.enable = true;
                  fail2ban.enable = true;
                  telegraf.enable = true;
                  ttrss.enable = false;
                  adguardhome.enable = false;

                  influxdb2.enable = true;
                };
              };
            };

            extraimports = [
              #baseInstallerImport
            ];
          };

        # raspberry pi @ home (192.168.0.120 / 10.100.0.2)
        beta =
          let
            hardware-config = import (./machines/beta);
            users = with raspiUsers; [ nixos ];
          in
          raspiUtil.host.mkHost {
            inherit hardware-config users;

            systemConfig = {
              core = {
                bootLoader = null;
                hostName = "beta";
                docker = true;
              };

              server = {
                enable = true;
                services = {
                  caddy.proxy = {
                    "jellyfin" = 8096;
                    "calibre" = 8083;
                  };

                  unbound = {
                    enable = true;
                    apps = {
                      "jellyfin" = "beta";
                      "calibre" = "beta";
                      "influx" = "alpha";
                    };
                  };

                  openssh.enable = true;
                  telegraf.enable = true;
                  iperf.enable = true;

                  syncthing.enable = true;
                  jellyfin.enable = true;

                  calibre.enable = true;
                };
              };
              fileshare = {
                enable = true;
                shares = {
                  enable = true;
                  dirs = [ "/media" ];
                };
                samba = {
                  #enable = true;
                  dirs = [ "/media" ];
                };
              };
            };

            extraimports = [
              nixos-hardware.nixosModules.raspberry-pi-4
              raspInstallerImport
            ];
          };

        # desktop @ home (192.168.8.230 / 10.100.0.3)
        gamma =
          let
            hardware-config = import (./machines/gamma);
            users = with systemUsers; [ maelstroem ];
          in
          util.host.mkHost {
            inherit hardware-config users;

            systemConfig = {
              core = {
                docker = true;
                hostName = "gamma";
              };

              wireguard.enable = true;
              mullvad.enable = true;
              server.services.telegraf.enable = false;

              nvidia.enable = true;
              desktop.enable = true;
              sound.enable = true;
              yubikey.enable = true;

              video = {
                enable = true;
                driver = "nvidia";
                manager = "gnome";
              };

              fileshare = {
                enable = true;
                mount = {
                  enable = true;
                  binds = [
                    {
                      ip = "192.168.0.120";
                      dirs = [ "/media" ];
                    }
                  ];
                };
              };

              dns.nameserver = "beta";

              development = {
                enable = false;
                adb.enable = false;
              };
            };

            extraimports = [
              #baseInstallerImport
            ];
          };

        # workplace-issued thinkpad (10.100.0.4)
        nixos-laptop =
          let
            hardware-config = import (./machines/nixos-laptop);
            users = with systemUsers; [ nixos ];
          in
          util.host.mkHost {
            inherit hardware-config users;

            systemConfig = {
              wireguard.enable = true;
              dns.nameserver = "beta";
              mullvad.enable = true;

              core.hostName = "nixos-laptop";
              core.enableBluetooth = true;

              sound.enable = true;
              yubikey.enable = true;

              server.services.telegraf.enable = false;

              laptop = {
                enable = true;
                wirelessInterfaces = [ "wlp0s20f3" ];
              };

              video = {
                enable = true;
                manager = "sway";
              };
            };

            extraimports = [
              #nixos-hardware.nixosModules.lenovo-thinkpad-t490
              #baseInstallerImport
            ];
          };

      };

      # shortcut for building with `nix build`
      systems = {
        nixos-laptop = self.nixosConfigurations.nixos-laptop.config.system.build.toplevel;
        alpha = self.nixosConfigurations.alpha.config.system.build.toplevel;
        beta = self.nixosConfigurations.beta.config.system.build.toplevel;
        gamma = self.nixosConfigurations.gamma.config.system.build.toplevel;
      };

      # shortcut for building a raspberry pi sd image
      images = {
        beta = self.nixosConfigurations.beta.config.system.build.sdImage;
      };

      # deploy config
      deploy.nodes = {
        alpha = {
          #hostname = "148.251.102.93";
          hostname = "10.100.0.1";
          sshUser = "root";
          profiles.system.path = deploy-rs.lib."${system}".activate.nixos self.nixosConfigurations.alpha;
        };

        beta = {
          hostname = "10.100.0.2";
          sshUser = "root";
          profiles.system.path = deploy-rs.lib."aarch64-linux".activate.nixos self.nixosConfigurations.beta;
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
