{
  # todo:
  # - clone rassword store into home dir
  inputs = {
    # unstable > stable
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

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
    deploy-rs.url = "github:serokell/deploy-rs";

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
    sops-nix-src.url = "github:Mic92/sops-nix";
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
    , ...
    }@inputs:
    let
      inherit (nixpkgs) lib;
      system = "x86_64-linux";
      sops-nix = sops-nix-src.nixosModules.sops;

      overlays = [
        nur-src.overlay
        (import ./custom_pkgs)
        (import ./overlays/gopass-rofi.nix { inherit inputs; })
        (import ./overlays/rofi-overlay.nix { inherit inputs; })
        devshell.overlay
        sops-nix-src.overlay
      ];

      nixpkgsFor = system:
        import nixpkgs {
          inherit system overlays;
          config.allowUnfree = true;
        };

      utilFor = system:
        import ./lib rec {
          inherit home-manager lib overlays sops-nix system;
          pkgs = nixpkgsFor system;
        };

      systemUsersFor = pkgs: {
        nixos = {
          name = "nixos";
          groups = [ "wheel" "video" "audio" "docker" "dialout" ];
          shell = pkgs.zsh;
          uid = 1001;
        };

        maelstroem = {
          name = "maelstroem";
          groups = [ "wheel" "video" "audio" "docker" "dialout" ];
          shell = pkgs.zsh;
          uid = 1000;
        };
      };

      aarch64_pkgs = nixpkgsFor "aarch64-linux";
      raspiUtil = utilFor "aarch64-linux";
      raspiUsers = systemUsersFor aarch64_pkgs;

      pkgs = nixpkgsFor "x86_64-linux";
      util = utilFor "x86_64-linux";
      systemUsers = systemUsersFor pkgs;

      shells =
        let
          shellPackages = with pkgs; [
            fd
            nixpkgs-fmt
            sops
            age

            sops-import-keys-hook
            ssh-to-age
          ];
        in
        {
          legacyShell = pkgs.mkShell {
            sopsPGPKeys = [
              "./keys/beta.asc"
              "./keys/philipp.asc"
            ];
            buildInputs = shellPackages;
          };

          devShell = pkgs.devshell.mkShell {
            name = "dotfiles";
            packages = shellPackages;

            commands = [
              {
                name = "fmt";
                help = "Autoformat Nix files";
                command = "nixpkgs-fmt \${@} $PRJ_ROOT";
                category = "dev";
              }

              {
                name = "evalnix";
                help = "Check Nix parsing";
                command = "fd --extension nix --exec nix-instantiate --parse --quiet {} >/dev/null";
                category = "dev";
              }

              {
                name = "sops";
                help = "Create/edit a secret file";
                package = pkgs.sops;
                category = "dev";
              }

              {
                name = "deploy";
                help = "deploy to remote hosts";
                package = deploy-rs.packages."${system}".deploy-rs;
                category = "remote";
              }

              {
                name = "update";
                help = "Update + Commit the Lock File";
                command = "nix flake update --commit-lock-file";
                category = "system";
              }

              {
                name = "switch";
                help = "Switch to a NixOS Configuration (local)";
                command = ''
                  if [[ -z "$@" || "$1" == "help" ]]; then
                    echo -e "Available configs:"
                    nix flake show 2>/dev/null | grep nixosConfigurations -A 200 | tail +2 | sed 's/:.*//'
                  else
                    sudo nixos-rebuild --flake ".#$1" switch
                  fi
                '';
                category = "system";
              }

              {
                name = "uswitch";
                help = "Build + switch to a user configuration with home-manager";
                command = ''
                  if [[ -z "$@" || "$1" == "help" ]]; then
                    echo -e "Available configs:"
                    echo -e "\tnixos"
                    echo -e "\tmaelstroem"
                  else
                    nix build ".#homeManagerConfigurations.$1.activationPackage" && result/activate
                  fi
                '';
                category = "system";
              }
            ];
          };
        };
    in
    {
      #devShell."${system}" = shells.legacyShell;
      devShell."${system}" = shells.devShell;

      homeManagerConfigurations =
        let
          gpgKey = "BDCD0C4E9F252898";
          sshKey = "F40506C8F342CC9DF1CC8E9C50DD4037D2F6594B";
        in
        {
          nixos = util.user.mkHMUser {
            userConfig = {
              # sway.enable = true;
              # music = {
              #   enable = false;
              #   spotifyd_device_name = "nixos";
              # };

              git = {
                enable = true;
                userName = "Philipp Herzog";
                userEmail = "p.herzog@fz-juelich.de";
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
            username = "nixos";
          };

          maelstroem = util.user.mkHMUser {
            userConfig = {
              music = {
                enable = true;
                spotifyd_device_name = "maelstroem";
              };

              kde.enable = true;
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

            extraPackages = with pkgs; [
              audacity
              chromium
              citra
              multimc
              obs-studio
              citra
              openttd
            ];

            username = "maelstroem";
          };
        };

      nixosConfigurations = {
        # workplace-issued thinkpad
        nixos-laptop =
          let
            hardware-config = import (./machines/nixos-laptop);
            users = with systemUsers; [ nixos ];
          in
          util.host.mkHost {
            inherit hardware-config users;
            systemConfig = {
              core.hostName = "nixos-laptop";
              laptop = {
                enable = true;
                wirelessInterfaces = [ "wlp0s20f3" ];
              };
              sound.enable = true;
              video = {
                enable = true;
                manager = "sway";
              };
              yubikey = {
                enable = true;
                yubifile = ./ykchal/nixos-14321676;
                username = "nixos";
              };
            };

            extramods = [
              #nixos-hardware.nixosModules.lenovo-thinkpad-t490
            ];
          };

        # desktop @ home
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
                hostName = "nix-desktop";
              };
              sound.enable = true;
              video = {
                enable = true;
                driver = "nvidia";
                manager = "kde";
              };
              yubikey = {
                enable = true;
                yubifile = ./ykchal/maelstroem-14321676;
                username = "maelstroem";
              };
            };

            extramods = [
              (import "${localDev}/nixos/modules/services/networking/innernet.nix")
            ];
          };

        # vm on a hetzner server, debian host
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
              server.enable = true;
              webapps.enable = true;
            };

            extramods = [
              (import "${localDev}/nixos/modules/services/networking/innernet.nix")
            ];
          };

        # raspberry pi
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
                hostName = "nixos-pi";
              };
              server = {
                enable = true;
                sshKeys = [
                  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCoABVjBx1az00D8EBjw9/NS9luqO2lN4Y87/2xsQqPTx9P7aXzfX53TwmU9Wpmp7qOIKykd8GSkBdCizMEzgaGmJl6+Di2GYvEfN0NrsLdBrjmIh7AQyR6UbY7qoTFjZ28864rk9QV9to2R1APL7o1wzdmCrFtTsemV+lw9MglqcPLT+ae2mba9fD84FFDmcSJMg5x1QHrO5GuWg/Ng7SE1eRhDbDmz66+HhdgvRRDJ9VwPGcH5ruXsDKvi/nrLVSxw7afvuM5KcNYoy+9CrA/N10cO5zdn4/q2DLYujkOvAucCDJ4bUEe8q6xEZw1LfCjKWIoFxzt+hetfkjS/Y3wWWTcHfcOx/BV6cOxyAFUGbu9RX/iUpyt8LAfjQv6L1zcD7vxYpfKz88jI/4zL7mHwILg+XQklBeiBsEQ4PyO1+4oIfuju241hVk+bFZYUD+AzzCNv7GKNNHe4aa4MWN6RLLhNxe9QlOTnsw0l2XNypr62Q1V8nxZkSY7mW8Hn0hLxTT82mTLuAff2yHPu+w+i0ELkk0BO28apxU1dPPbScHvojRlXTwIBvH3HN6TWdj2YnNFMdGvZgxxFNbi4l/7Gar1FKgi79KOwcm89ATmjONfbQMub+TaeBACefMZ9Q7uzbWeNO3mZpVA8nvM5eleqLemxYoeAQBuYjBjJlAHzQ== cardno:000614321676"
                  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCoABVjBx1az00D8EBjw9/NS9luqO2lN4Y87/2xsQqPTx9P7aXzfX53TwmU9Wpmp7qOIKykd8GSkBdCizMEzgaGmJl6+Di2GYvEfN0NrsLdBrjmIh7AQyR6UbY7qoTFjZ28864rk9QV9to2R1APL7o1wzdmCrFtTsemV+lw9MglqcPLT+ae2mba9fD84FFDmcSJMg5x1QHrO5GuWg/Ng7SE1eRhDbDmz66+HhdgvRRDJ9VwPGcH5ruXsDKvi/nrLVSxw7afvuM5KcNYoy+9CrA/N10cO5zdn4/q2DLYujkOvAucCDJ4bUEe8q6xEZw1LfCjKWIoFxzt+hetfkjS/Y3wWWTcHfcOx/BV6cOxyAFUGbu9RX/iUpyt8LAfjQv6L1zcD7vxYpfKz88jI/4zL7mHwILg+XQklBeiBsEQ4PyO1+4oIfuju241hVk+bFZYUD+AzzCNv7GKNNHe4aa4MWN6RLLhNxe9QlOTnsw0l2XNypr62Q1V8nxZkSY7mW8Hn0hLxTT82mTLuAff2yHPu+w+i0ELkk0BO28apxU1dPPbScHvojRlXTwIBvH3HN6TWdj2YnNFMdGvZgxxFNbi4l/7Gar1FKgi79KOwcm89ATmjONfbQMub+TaeBACefMZ9Q7uzbWeNO3mZpVA8nvM5eleqLemxYoeAQBuYjBjJlAHzQ== (none)"
                ];
              };

            };

            extramods = [
              nixos-hardware.nixosModules.raspberry-pi-4
            ];
          };
      };

      systems = {
        nixos-laptop = self.nixosConfigurations.nixos-laptop.config.system.build.toplevel;
        alpha = self.nixosConfigurations.alpha.config.system.build.toplevel;
        beta = self.nixosConfigurations.beta.config.system.build.toplevel;
        gamma = self.nixosConfigurations.gamma.config.system.build.toplevel;
      };

      # deploy config
      deploy.nodes = {
        #   alpha = {
        #     hostname = "148.251.102.93";
        #     sshUser = "root";
        #     profiles.system.path = deploy-rs.lib."${system}".activate.nixos self.nixosConfigurations.alpha;
        #   };

        beta = {
          hostname = "192.168.8.236";
          sshUser = "root";
          profiles.system.path = deploy-rs.lib."aarch64-linux".activate.nixos self.nixosConfigurations.beta;
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
