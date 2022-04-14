# SSH fix: `export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)`
{
  # todo:
  # - clone rassword store into home dir
  inputs = {
    # unstable > stable
    #nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/master";

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

    # my fork of nixpkgs
    #localDev.url = "/platte/Documents/gits/nixpkgs/";
    localDev.url = "github:PhilTaken/nixpkgs/innernet-module";

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
    , localDev
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
              music = {
                enable = true;
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
            extraPackages = pkgs: with pkgs; [ ];
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

            extraPackages = pkgs: with pkgs; [ hakuneko ];
          };
        };

      nixosConfigurations = {
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
                docker = true;
                hostName = "alpha";
                bootLoader = "grub";
                grubDevice = "/dev/sda";
              };
              server = {
                enable = true;
                services = {
                  openssh.enable = true;
                  fail2ban.enable = true;
                  telegraf.enable = false;
                  ttrss.enable = true;
                  adguardhome.enable = false;

                  influxdb2 = {
                    enable = true;
                    url = "0.0.0.0";
                  };
                };
              };
            };

            extraimports = [
              (import "${localDev}/nixos/modules/services/networking/innernet.nix")
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
              dns = {
                unbound.enable = false;
                traefik.enable = false;
                #subdomains = {
                  #"home".ip = "10.100.0.2";
                  #"jellyfin".ip = "10.100.0.2";
                  #"syncthing".ip = "10.100.0.2";
                  #"notes".ip = "10.100.0.2";
                  #"influx".ip = "10.100.0.1";
                #};
              };
              server = {
                enable = true;
                services = {
                  openssh.enable = true;
                  telegraf.enable = false;
                  iperf.enable = true;

                  syncthing.enable = true;
                  jellyfin.enable = true;
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
              "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix"
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
              video = {
                enable = true;
                driver = "nvidia";
                manager = "gnome";
              };
              yubikey.enable = true;
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

              development = {
                enable = false;
                adb.enable = false;
              };
            };

            extraimports = [
              #(import "${localDev}/nixos/modules/services/networking/innernet.nix")
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
              wireguard.enable = false;
              core.hostName = "nixos-laptop";
              server = {
                enable = true;
                services.telegraf.enable = false;
              };
              mullvad.enable = false;
              laptop = {
                enable = true;
                wirelessInterfaces = [ "wlp0s20f3" ];
              };
              sound.enable = true;
              video = {
                enable = true;
                manager = "sway";
              };
              yubikey.enable = true;
            };

            extraimports = [
              #nixos-hardware.nixosModules.lenovo-thinkpad-t490
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

      # shortcut for building the sd card image for the raspberry pi
      images = {
        beta = self.nixosConfigurations.beta.config.system.build.sdImage;
      };

      # deploy config
      deploy.nodes = {
        alpha = {
          hostname = "148.251.102.93";
          sshUser = "root";
          profiles.system.path = deploy-rs.lib."${system}".activate.nixos self.nixosConfigurations.alpha;
        };

        beta = {
          hostname = "192.168.0.120";
          sshUser = "root";
          profiles.system.path = deploy-rs.lib."aarch64-linux".activate.nixos self.nixosConfigurations.beta;
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

    };
}
