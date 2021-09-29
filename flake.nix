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
  };
  outputs =
    { self
    , nixpkgs
    , home-manager
    , deploy-rs
    , nur-src
    , localDev
    , devshell
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
      ];

      pkgs = import nixpkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };

      util = import ./lib {
        inherit system pkgs home-manager lib overlays;
      };

      inherit (util) user;
      inherit (util) host;

      users = {
        nixos = user.mkSystemUser {
          name = "nixos";
          groups = [ "wheel" "video" "audio" "docker" "dialout" ];
          shell = pkgs.zsh;
          uid = 1001;
        };

        maelstroem = user.mkSystemUser {
          name = "maelstroem";
          groups = [ "wheel" "video" "audio" "docker" "dialout" ];
          shell = pkgs.zsh;
          uid = 1000;
        };
      };
    in
    {
      devShell."${system}" = pkgs.devshell.mkShell {
        name = "dotfiles";
        packages = with pkgs; [
          fd
          nixpkgs-fmt
        ];

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
        ];
      };

      homeManagerConfigurations = {
        nixos = user.mkHMUser {
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
              signKey = "BDCD0C4E9F252898";
            };
            mail.enable = true;
            neovim.enable = true;
            ssh.enable = true;
            zsh_full.enable = true;
          };

          username = "nixos";
        };

        maelstroem = user.mkHMUser {
          userConfig = {
            # music = {
            #   enable = true;
            #   spotifyd_device_name = "maelstroem";
            # };

            kde.enable = true;
            git = {
              enable = true;
              userName = "Philipp Herzog";
              userEmail = "philipp.herzog@protonmail.com";
              signKey = "BDCD0C4E9F252898";
            };
            mail.enable = true;
            neovim.enable = true;
            ssh.enable = true;
            zsh_full.enable = true;
          };

          username = "maelstroem";
        };
      };

      nixosConfigurations = {
        # workplace-issued thinkpad
        nixos-laptop = host.mkHostWithUser {
          host = "nixos-laptop";
          username = "nixos";
          extramods = [
            #nixos-hardware.nixosModules.lenovo-thinkpad-t490
          ];
        };

        # desktop @ home
        gamma = host.mkHostWithUser {
          host = "gamma";
          username = "maelstroem";
          enable_xorg = true;
          extramods = [
            (import "${localDev}/nixos/modules/services/networking/innernet.nix")
          ];
        };

        # desktop @ home (older)
        gamma_old = host.mkHostWithUser {
          host = "gamma_old";
          username = "maelstroem";
          enable_xorg = true;
          extramods = [
            (import "${localDev}/nixos/modules/services/networking/innernet.nix")
          ];
        };

        # vm on a hetzner server, debian host
        alpha = host.mkHostWithUser {
          host = "alpha";
          extramods = [
            (import "${localDev}/nixos/modules/services/networking/innernet.nix")
          ];
        };

        # for the (planned) raspberry pi
        #beta = host.mkHost {
        #  host = "beta";
        #};
      };

      # deploy config
      deploy.nodes = {
        alpha = {
          hostname = "148.251.102.93";
          sshUser = "root";
          profiles.system.path = deploy-rs.lib."${system}".activate.nixos self.nixosConfigurations.alpha;
        };

        #beta = {
        #   hostname = "test";
        #   sshUser = "root";
        #   profiles.system.path = deploy-rs.lib."${system}".activate.nixos self.nixosConfigurations.beta;
        #};
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
