{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    #nixpkgs.url = "github:nixos/nixpkgs/master";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    spicetify.url = "github:PhilTaken/spicetify-nix";
    polymc.url = "github:PolyMC/PolyMC";

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
  };

  outputs = { self, nixpkgs, ... }@inputs: let
    inherit (nixpkgs) lib;
    system = "x86_64-linux";

    libFor = system: import ./lib { inherit system inputs; };
    net = import ./network.nix {};

    util = libFor "x86_64-linux";
    raspiUtil = libFor "aarch64-linux";
    pkgs = util.pkgs;
  in {
    devShells."${system}".default = util.shells.devShell;

    overlays.default = (import ./custom_pkgs);

    homeManagerConfigurations = {
      nixos = util.user.mkHMUser {
        username = "nixos";
        userConfig = {
          wms.sway.enable = true;
          wms.bars.waybar.enable = true;
        };

        extraPackages = pkgs: with pkgs; [
          gnome3.adwaita-icon-theme
          xournalpp
        ];
      };

      maelstroem = util.user.mkHMUser {
        username = "maelstroem";
        userConfig = {
          firefox = {
            enable = true;
            wayland = false;
          };

          # de/wm config
          wms.i3.enable = true;
          wms.bars.eww.enable = true;
        };

        extraPackages = pkgs: with pkgs; [
          nur.repos.shados.tmm
          plover.dev
        ];
      };
    };

    nixosConfigurations = let
      wireguard.enable = true;
      nebula.enable = true;
    in {
      # usb stick iso
      x86-iso = util.iso.mkIso "isoInstall";

      # desktop @ home
      gamma = let
        hardware-config = import (./machines/gamma);
        users = [{ name = "maelstroem"; uid = 1000; }];
      in util.host.mkHost {
        inherit hardware-config users;

        systemConfig = {
          inherit wireguard nebula;

          core.hostName = "gamma";
          core.enableBluetooth = true;

          dns.nameserver = "beta";
          mullvad.enable = true;

          nvidia.enable = true;
          desktop.enable = true;

          video = {
            driver = "nvidia";
            manager = "xfce";
          };
        };
      };

      # workplace-issued thinkpad
      nixos-laptop = let
        hardware-config = import (./machines/nixos-laptop);
        users = [{ name = "nixos"; uid = 1001; }];
      in util.host.mkHost {
        inherit hardware-config users;

        systemConfig = {
          inherit wireguard nebula;

          core.hostName = "nixos-laptop";
          laptop.enable = true;
          laptop.wirelessInterfaces = [ "wlp0s20f3" ];
          dns.nameserver = "beta";

          mullvad.enable = true;
          video.manager = "sway";
        };
      };
    } // builtins.mapAttrs (servername: services: let
      sUtil = if servername == "beta" then raspiUtil else util;
    in sUtil.server.mkServer { inherit servername services; }) net.services;

    # shortcut for building with `nix build`
    systems = builtins.mapAttrs (system: _: self.nixosConfigurations.${system}.config.system.build.toplevel) self.nixosConfigurations;

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
        profiles.system.path = inputs.deploy-rs.lib."${system}".activate.nixos self.nixosConfigurations.alpha;
      };

      beta = {
        #hostname = "10.200.0.2";
        hostname = "192.168.0.120";
        sshUser = "root";
        profiles.system.path = inputs.deploy-rs.lib."aarch64-linux".activate.nixos self.nixosConfigurations.beta;
      };

      delta = {
        #hostname = "10.200.0.4";
        hostname = "192.168.0.21";
        sshUser = "root";
        profiles.system.path = inputs.deploy-rs.lib."${system}".activate.nixos self.nixosConfigurations.delta;
      };
    };

    # filter darwin system checks
    checks = lib.filterAttrs
      (system: _: ! lib.hasInfix "darwin" system)
      (builtins.mapAttrs
        (system: deployLib: deployLib.deployChecks self.deploy)
        inputs.deploy-rs.lib);
  };
}
