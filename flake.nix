{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    #nixpkgs.url = "github:nixos/nixpkgs/master";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    spicetify.url = "github:PhilTaken/spicetify-nix";
    polymc.url = "github:PolyMC/PolyMC";
    comma.url = "github:nix-community/comma";
    comma.inputs.nixpkgs.follows = "nixpkgs";

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

    # for secret managment
    sops-nix-src = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly = {
      url = "github:neovim/neovim?dir=contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spacemacs-git = {
      url = "github:syl20bnr/spacemacs";
      flake = false;
    };

    eww-src = {
      url = "github:elkowar/eww";
      flake = false;
    };

    neovide-src = {
      url = "github:neovide/neovide";
      flake = false;
    };

    tmux-colorscheme = {
      url = "github:catppuccin/tmux";
      flake = false;
    };

    catppucin-wallpapers = {
      url = "github:catppuccin/wallpapers";
      flake = false;
    };
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
    , spacemacs-git
    , comma
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
        (import ./overlays/eww.nix { inherit inputs; })
        #(import ./overlays/neovide.nix {inherit inputs; })
        devshell.overlay
        sops-nix-src.overlay
        deploy-rs.overlay
        neovim-nightly.overlay
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
          groups = [ "wheel" "video" "audio" "docker" "dialout" "adbusers" "gpio" ];
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

      gpgKey = "BDCD0C4E9F252898";
      gpg-sshKey = "F40506C8F342CC9DF1CC8E9C50DD4037D2F6594B";

      net = import ./network.nix {};
      iplot = net.networks.default;
    in {
      #devShells."${system}".default = util.shells.legacyShell;
      devShells."${system}".default = util.shells.devShell;

      overlays.default = (import ./custom_pkgs);

      homeManagerConfigurations = let
        git = {
          enable = true;
          userName = "Philipp Herzog";
          userEmail = "philipp.herzog@protonmail.com";
          signKey = gpgKey;
        };
        editors = {
          spacemacs = {
            enable = false;
            spacemacs-path = "${spacemacs-git}";
          };
          neovim.enable = true;
        };
        ssh.enable = true;
        gpg = {
          inherit gpgKey;
          enable = true;
          sshKeys = [ gpg-sshKey ];
        };
        zsh_full.enable = true;
        music.enable = true;
        mail.enable = true;
        firefox.enable = true;
      in {
        nixos = util.user.mkHMUser {
          username = "nixos";
          userConfig = {
            inherit git editors ssh gpg zsh_full music mail firefox;
            wms = {
              sway.enable = true;
              bars.waybar.enable = true;
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
            inherit git editors ssh gpg zsh_full music mail;

            firefox = {
              enable = true;
              wayland = false;
            };

            # de/wm config
            wms = {
              tools.udiskie.enable = true;
              # TODO:
              # xmonad.enable = true;

              i3.enable = true;
              bars.eww.enable = true;
              #bars.polybar.enable = true;
            };

          };

          extraPackages = pkgs: with pkgs; [
            nur.repos.shados.tmm
            comma.packages.${system}.comma
            plover.dev
          ];
        };
      };

      nixosConfigurations = let
        # include in the imports to build an iso image for the respective systems (TODO: check if it works)
        baseInstallerImport = "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-base.nix";
        raspInstallerImport = "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix";

        wireguard.enable = true;
        nebula.enable = true;

        # TODO: generate this set from list
        dnsBinds = {
          "jellyfin" = "delta";
          "gitea" = "delta";
          "calibre" = "beta";
          "influx" = "alpha";
        };
      in {
        x86-iso = util.host.mkHost {
          users = [ systemUsers.nixos ];
          systemConfig = {
            core.hostName = "isoInstall";
            wireguard.enable = false;
            server.services.openssh.enable = true;
          };
          extraimports = [ baseInstallerImport ];
        };

        # vm on a hetzner server, debian host (10.100.0.1)
        alpha = util.server.mkServer {
          servername = "alpha";
          services = [ "influxdb2" ];
        };

        # mini nas @ home (192.168.0.21 / 10.100.0.5 / 10.200.0.4)
        delta = util.server.mkServer {
          servername = "delta";
          services = [
            "gitea"
            "jellyfin"
            #"calibre"
            {
              syncthing = {
                enable = false;
                dataFolder = "/media/syncthing/data";
                configFolder = "/media/syncthing/config";
              };
            }
          ];
          fileshare.mount.binds = [
            {
              ip = iplot.beta;
              dirs = [ "/media" ];
            }
          ];
        };


        # raspberry pi @ home (192.168.0.120 / 10.100.0.2)
        beta = raspiUtil.server.mkServer {
          servername = "beta";
          services = [
            "jellyfin"       # TODO: phase out
            "calibre"
            "syncthing"
            {
              unbound.apps = dnsBinds;
              telegraf.inputs.extrasensors = true;
            }
          ];
          fileshare.shares.dirs = [ "/media" ];

          extraimports = [
            nixos-hardware.nixosModules.raspberry-pi-4
            raspInstallerImport
          ];
        };

        # desktop @ home (192.168.8.230 / 10.100.0.3)
        gamma = let
          hardware-config = import (./machines/gamma);
          users = with systemUsers; [ maelstroem ];
        in util.host.mkHost {
          inherit hardware-config users;

          systemConfig = {
            inherit wireguard nebula;

            core.hostName = "gamma";
            core.enableBluetooth = true;

            dns.nameserver = "beta";
            mullvad.enable = true;

            sound.enable = true;
            yubikey.enable = true;

            nvidia.enable = true;
            desktop.enable = true;

            video = {
              enable = true;
              driver = "nvidia";
              manager = "xfce";
            };

            server.services.telegraf.enable = true;

            fileshare.mount.binds = [
              {
                ip = iplot.beta;
                dirs = [ "/media" ];
              }
            ];

          };
        };

        # workplace-issued thinkpad (10.100.0.4)
        nixos-laptop = let
          hardware-config = import (./machines/nixos-laptop);
          users = with systemUsers; [ nixos ];
        in util.host.mkHost {
          inherit hardware-config users;

          systemConfig = {
            inherit wireguard nebula;

            core.hostName = "nixos-laptop";
            core.enableBluetooth = true;

            dns.nameserver = "beta";
            mullvad.enable = true;

            sound.enable = true;
            yubikey.enable = true;


            laptop = {
              enable = true;
              wirelessInterfaces = [ "wlp0s20f3" ];
            };

            video = {
              enable = true;
              manager = "sway";
            };

            server.services.telegraf.enable = false;
          };
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
      packages."${system}" = {
        x86-iso = self.nixosConfigurations.x86-iso.config.system.build.isoImage;
        beta-iso = self.nixosConfigurations.beta.config.system.build.sdImage;
      };

      # deploy config
      deploy.nodes = {
        alpha = {
          hostname = "148.251.102.93";
          #hostname = "10.200.0.1";
          sshUser = "root";
          profiles.system.path = deploy-rs.lib."${system}".activate.nixos self.nixosConfigurations.alpha;
        };

        beta = {
          #hostname = "10.200.0.2";
          hostname = "192.168.0.120";
          sshUser = "root";
          profiles.system.path = deploy-rs.lib."aarch64-linux".activate.nixos self.nixosConfigurations.beta;
        };

        delta = {
          #hostname = "10.200.0.4";
          hostname = "192.168.0.21";
          sshUser = "root";
          profiles.system.path = deploy-rs.lib."${system}".activate.nixos self.nixosConfigurations.delta;
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
