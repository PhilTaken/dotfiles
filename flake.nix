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
        neovim-nightly.overlay
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
      #devShell."${system}" = util.shells.legacyShell;
      devShell."${system}" = util.shells.devShell;

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
                spotifyd_device_name = "nixos";
              };
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
          };

          maelstroem = util.user.mkHMUser {
            username = "maelstroem";

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
              chromium
              citra
              multimc
              openttd
            ];
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
              yubikey.enable = true;
            };

            extraimports = [
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
                hostName = "gamma";
              };
              nvidia.enable = true;
              desktop.enable = true;
              sound.enable = true;
              video = {
                enable = true;
                driver = "nvidia";
                manager = "kde";
              };
              yubikey.enable = true;
            };

            extraimports = [
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
              server = {
                enable = true;
                sshKeys = [
                  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCoABVjBx1az00D8EBjw9/NS9luqO2lN4Y87/2xsQqPTx9P7aXzfX53TwmU9Wpmp7qOIKykd8GSkBdCizMEzgaGmJl6+Di2GYvEfN0NrsLdBrjmIh7AQyR6UbY7qoTFjZ28864rk9QV9to2R1APL7o1wzdmCrFtTsemV+lw9MglqcPLT+ae2mba9fD84FFDmcSJMg5x1QHrO5GuWg/Ng7SE1eRhDbDmz66+HhdgvRRDJ9VwPGcH5ruXsDKvi/nrLVSxw7afvuM5KcNYoy+9CrA/N10cO5zdn4/q2DLYujkOvAucCDJ4bUEe8q6xEZw1LfCjKWIoFxzt+hetfkjS/Y3wWWTcHfcOx/BV6cOxyAFUGbu9RX/iUpyt8LAfjQv6L1zcD7vxYpfKz88jI/4zL7mHwILg+XQklBeiBsEQ4PyO1+4oIfuju241hVk+bFZYUD+AzzCNv7GKNNHe4aa4MWN6RLLhNxe9QlOTnsw0l2XNypr62Q1V8nxZkSY7mW8Hn0hLxTT82mTLuAff2yHPu+w+i0ELkk0BO28apxU1dPPbScHvojRlXTwIBvH3HN6TWdj2YnNFMdGvZgxxFNbi4l/7Gar1FKgi79KOwcm89ATmjONfbQMub+TaeBACefMZ9Q7uzbWeNO3mZpVA8nvM5eleqLemxYoeAQBuYjBjJlAHzQ== cardno:000614321676"
                  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCoABVjBx1az00D8EBjw9/NS9luqO2lN4Y87/2xsQqPTx9P7aXzfX53TwmU9Wpmp7qOIKykd8GSkBdCizMEzgaGmJl6+Di2GYvEfN0NrsLdBrjmIh7AQyR6UbY7qoTFjZ28864rk9QV9to2R1APL7o1wzdmCrFtTsemV+lw9MglqcPLT+ae2mba9fD84FFDmcSJMg5x1QHrO5GuWg/Ng7SE1eRhDbDmz66+HhdgvRRDJ9VwPGcH5ruXsDKvi/nrLVSxw7afvuM5KcNYoy+9CrA/N10cO5zdn4/q2DLYujkOvAucCDJ4bUEe8q6xEZw1LfCjKWIoFxzt+hetfkjS/Y3wWWTcHfcOx/BV6cOxyAFUGbu9RX/iUpyt8LAfjQv6L1zcD7vxYpfKz88jI/4zL7mHwILg+XQklBeiBsEQ4PyO1+4oIfuju241hVk+bFZYUD+AzzCNv7GKNNHe4aa4MWN6RLLhNxe9QlOTnsw0l2XNypr62Q1V8nxZkSY7mW8Hn0hLxTT82mTLuAff2yHPu+w+i0ELkk0BO28apxU1dPPbScHvojRlXTwIBvH3HN6TWdj2YnNFMdGvZgxxFNbi4l/7Gar1FKgi79KOwcm89ATmjONfbQMub+TaeBACefMZ9Q7uzbWeNO3mZpVA8nvM5eleqLemxYoeAQBuYjBjJlAHzQ== (none)"
                ];
              };
              webapps.enable = true;
            };

            extraimports = [
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
                hostName = "beta";
              };
              server = {
                enable = true;
                sshKeys = [
                  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCoABVjBx1az00D8EBjw9/NS9luqO2lN4Y87/2xsQqPTx9P7aXzfX53TwmU9Wpmp7qOIKykd8GSkBdCizMEzgaGmJl6+Di2GYvEfN0NrsLdBrjmIh7AQyR6UbY7qoTFjZ28864rk9QV9to2R1APL7o1wzdmCrFtTsemV+lw9MglqcPLT+ae2mba9fD84FFDmcSJMg5x1QHrO5GuWg/Ng7SE1eRhDbDmz66+HhdgvRRDJ9VwPGcH5ruXsDKvi/nrLVSxw7afvuM5KcNYoy+9CrA/N10cO5zdn4/q2DLYujkOvAucCDJ4bUEe8q6xEZw1LfCjKWIoFxzt+hetfkjS/Y3wWWTcHfcOx/BV6cOxyAFUGbu9RX/iUpyt8LAfjQv6L1zcD7vxYpfKz88jI/4zL7mHwILg+XQklBeiBsEQ4PyO1+4oIfuju241hVk+bFZYUD+AzzCNv7GKNNHe4aa4MWN6RLLhNxe9QlOTnsw0l2XNypr62Q1V8nxZkSY7mW8Hn0hLxTT82mTLuAff2yHPu+w+i0ELkk0BO28apxU1dPPbScHvojRlXTwIBvH3HN6TWdj2YnNFMdGvZgxxFNbi4l/7Gar1FKgi79KOwcm89ATmjONfbQMub+TaeBACefMZ9Q7uzbWeNO3mZpVA8nvM5eleqLemxYoeAQBuYjBjJlAHzQ== cardno:000614321676"
                  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCoABVjBx1az00D8EBjw9/NS9luqO2lN4Y87/2xsQqPTx9P7aXzfX53TwmU9Wpmp7qOIKykd8GSkBdCizMEzgaGmJl6+Di2GYvEfN0NrsLdBrjmIh7AQyR6UbY7qoTFjZ28864rk9QV9to2R1APL7o1wzdmCrFtTsemV+lw9MglqcPLT+ae2mba9fD84FFDmcSJMg5x1QHrO5GuWg/Ng7SE1eRhDbDmz66+HhdgvRRDJ9VwPGcH5ruXsDKvi/nrLVSxw7afvuM5KcNYoy+9CrA/N10cO5zdn4/q2DLYujkOvAucCDJ4bUEe8q6xEZw1LfCjKWIoFxzt+hetfkjS/Y3wWWTcHfcOx/BV6cOxyAFUGbu9RX/iUpyt8LAfjQv6L1zcD7vxYpfKz88jI/4zL7mHwILg+XQklBeiBsEQ4PyO1+4oIfuju241hVk+bFZYUD+AzzCNv7GKNNHe4aa4MWN6RLLhNxe9QlOTnsw0l2XNypr62Q1V8nxZkSY7mW8Hn0hLxTT82mTLuAff2yHPu+w+i0ELkk0BO28apxU1dPPbScHvojRlXTwIBvH3HN6TWdj2YnNFMdGvZgxxFNbi4l/7Gar1FKgi79KOwcm89ATmjONfbQMub+TaeBACefMZ9Q7uzbWeNO3mZpVA8nvM5eleqLemxYoeAQBuYjBjJlAHzQ== (none)"
                ];
              };

            };

            extraimports = [
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
        alpha = {
          hostname = "148.251.102.93";
          sshUser = "root";
          profiles.system.path = deploy-rs.lib."${system}".activate.nixos self.nixosConfigurations.alpha;
        };

        beta = {
          hostname = "192.168.8.236";
          sshUser = "root";
          profiles.system.path = deploy-rs.lib."aarch64-linux".activate.nixos self.nixosConfigurations.beta;
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

    };
}
