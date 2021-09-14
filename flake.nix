{
  # todo:
  # - clone rassword store into home dir
  inputs = {
    # unstable > stable
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # my fork of nixpkgs
    #localDev.url = "/platte/Documents/gits/nixpkgs/";
    localDev.url = "github:PhilTaken/nixpkgs/innernet-module";

    # local user package managment
    home-manager.url = "github:nix-community/home-manager";

    # deploy remote setups
    deploy-rs.url = "github:serokell/deploy-rs";

    # devshell for some nice menu + easy command adding capabilities
    devshell.url = "github:numtide/devshell";
  };
  outputs =
    { self
    , nixpkgs
    , home-manager
    , deploy-rs
    , nur
    , localDev
    , devshell
    , ...
    }@inputs:
    let
      system = "x86_64-linux";
      overlays = [
        (import ./overlays/rofi-overlay.nix { inherit inputs; })
        (import ./overlays/gopass-rofi.nix { inherit inputs; })
        (import ./custom_pkgs)
        nur.overlay
        devshell.overlay
      ];

      pkgs = import nixpkgs {
        inherit system overlays;
        config.allowUnfree = true;
        config.permittedInsecurePackages = [
          "libgit2-0.27.10"
        ];
      };

      # every setup is a system + a user
      # the system is mainly used for hardware config, the user for software-specific setups
      # mkRemoteSetup is just a wrapper around nixosSystem that auto-imports host-specific
      # configuration based on the hosts name
      mkRemoteSetup = { host, username ? "nixos", enable_xorg ? false, extramods ? [ ] }:
        let
          # import host-specific config
          hostmod = import (./hosts + "/${host}") {
            inherit inputs pkgs username enable_xorg;
          };
        in
        # and pass it all to the og nixosSystem builder
        nixpkgs.lib.nixosSystem {
          inherit system pkgs;
          modules = [ hostmod ] ++ extramods;
        };

      # mkLocalSetup is just another wrapper around mkRemoteSetup. This method provides
      # any host / user combination with home-manager and a user-specific setup
      mkLocalSetup = { host, username ? "nixos", enable_xorg ? false, extramods ? [ ] }:
        let
          usermods = [
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users."${username}" = import (./users + "/${username}/home.nix") {
                inherit pkgs username enable_xorg;
              };
            }
          ] ++ extramods;
        in
        mkRemoteSetup {
          inherit host username enable_xorg;
          extramods = usermods;
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
            command = "nixpkgs-fmt \${@} $DEVSHELL_ROOT";
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

      # workplace-issued thinkpad
      nixosConfigurations.nixos-laptop = mkLocalSetup {
        host = "nixos-laptop";
        username = "nixos";
        extramods = [
          #nixos-hardware.nixosModules.lenovo-thinkpad-t490
        ];
      };

      # desktop @ home
      nixosConfigurations.gamma = mkLocalSetup {
        host = "gamma";
        username = "maelstroem";
        enable_xorg = true;
        extramods = [
          (import "${localDev}/nixos/modules/services/networking/innernet.nix")
        ];
      };

      # desktop @ home (older)
      nixosConfigurations.gamma_old = mkLocalSetup {
        host = "gamma_old";
        username = "maelstroem";
        enable_xorg = true;
        extramods = [
          (import "${localDev}/nixos/modules/services/networking/innernet.nix")
        ];
      };


      # vm on a hetzner server, debian host
      nixosConfigurations.alpha = mkRemoteSetup {
        host = "alpha";
        extramods = [
          (import "${localDev}/nixos/modules/services/networking/innernet.nix")
        ];
      };

      # for the (planned) raspberry pi
      #nixosConfigurations.beta = mkRemoteSetup {
      #  host = "beta";
      #};

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
