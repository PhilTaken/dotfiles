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

    hyprland = {
      url = "github:vaxerski/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zellij = {
      url = "github:zellij-org/zellij";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    arm-rs = {
      url = "github:PhilTaken/arm.rs";
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

  outputs = { self, nixpkgs, ... }@inputs:
    let
      inherit (nixpkgs) lib;
      libFor = system: import ./lib { inherit system inputs; };

      system = "x86_64-linux";
      util = libFor system;

      net = import ./network.nix { };

      hmUsers =
        let
          defaultConfig = {
            shells.fish.enable = true;
            tmux = {
              enable = true;
              defaultShell = "fish";
            };
            zellij.enable = true;
          };
        in
        {
          nixos = util.user.mkConfig {
            username = "nixos";
            userConfig = defaultConfig // {
              wms.hyprland.enable = true;
              wms.bars.waybar.enable = true;
            };

            extraPackages = pkgs: with pkgs; [
              gnome3.adwaita-icon-theme
              xournalpp
            ];
          };

          maelstroem = util.user.mkConfig {
            username = "maelstroem";
            userConfig = defaultConfig // {
              # de/wm config
              wms.i3.enable = true;
              wms.bars.eww.enable = true;
            };

            extraPackages = pkgs: with pkgs; [
              xfce.thunar
              guitarix
              qjackctl
              jack2Full

              nur.repos.shados.tmm
              plover.dev
            ];
          };

          jaid = util.user.mkConfig {
            username = "jaid";
            userConfig = {
              shells.zsh.enable = true;
              des.gnome.enable = true;
              firefox.wayland = false;
            };
          };
        };
    in
    {
      lib = util;

      devShells."${system}".default = util.shells.devShell;

      overlays.default = (import ./custom_pkgs);
      homeConfigurations = lib.mapAttrs (username: config: util.user.mkHMUser config) hmUsers;

      nixosConfigurations =
        let
          defaultConfig = {
            wireguard.enable = true;
            nebula.enable = true;
            server.services.telegraf.enable = false;
            dns.nameserver = builtins.head (builtins.attrNames (lib.filterAttrs (name: value: lib.hasInfix "unbound" (lib.concatStrings value)) net.services));
          };

          mkHMUsers = users: map (user: util.user.mkNixosModule hmUsers.${user}) users;
        in
        {
          # usb stick iso
          x86-iso = util.iso.mkIso "isoInstall";

          # desktop @ home
          gamma = util.host.mkHost rec {
            users = [ "maelstroem" "jaid" ];
            hmConfigs = mkHMUsers users;
            systemConfig = defaultConfig // {
              core.hostName = "gamma";
              core.enableBluetooth = true;

              development.adb.enable = true;
              mullvad.enable = true;

              nvidia.enable = true;
              desktop.enable = true;

              video = {
                driver = "nvidia";
                managers = [ "gnome" ];
              };
            };
          };

          # workplace-issued thinkpad
          nixos-laptop = util.host.mkHost rec {
            users = [ "nixos" ];
            hmConfigs = mkHMUsers users;
            systemConfig = defaultConfig // {
              core.hostName = "nixos-laptop";
              mullvad.enable = true;

              laptop.enable = true;
              laptop.wirelessInterfaces = [ "wlp0s20f3" ];

              #video.managers = [ "sway" ];
            };
          };
        } // builtins.mapAttrs
          (servername: services:
            let
              sUtil = if servername == "beta" then (libFor "aarch64-linux") else util;
            in
            sUtil.server.mkServer { inherit servername services; })
          net.services;

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

        #beta = {
        ##hostname = "10.200.0.2";
        #hostname = "192.168.0.120";
        #sshUser = "root";
        #profiles.system.path = inputs.deploy-rs.lib."aarch64-linux".activate.nixos self.nixosConfigurations.beta;
        #};

        delta = {
          #hostname = "10.200.0.5";
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
