{
  self,
  inputs,
  ...
}: let
  inherit (inputs.nixpkgs) lib;

  util = import ../../lib {inherit inputs self;};
  net = import ../../network.nix {};

  mkHMUsers = users: lib.listToAttrs (map (user: lib.nameValuePair user hmUsers.${user}) users);

  hmUsers = let
    mkConfig = lib.recursiveUpdate {
      ssh.enable = true;
      music.enable = true;
    };
  in {
    nixos = {
      userConfig = mkConfig {
        work.enable = true;

        # de/wm config
        wms.hyprland.enable = true;
        wms.bars.eww.enable = true;
      };
    };

    maelstroem = {
      userConfig = mkConfig {
        work.enable = true;

        # de/wm config
        wms.hyprland.enable = true;
        wms.bars.eww.enable = true;

        des.gnome.enable = true;
      };
    };

    jaid = {
      userConfig = mkConfig {
        terminals.defaultShell = "zsh";
        des.gnome.enable = true;
      };
    };

    philippherzog = {
      work.enable = true;

      editors.neovim.langs = {
        haskell = false;
        cpp = false;
        ts = false;
        python = true;
      };

      shells.fish.enable = true;
      gpg.enable = true;

      git = {
        enable = true;
        userName = "Philipp Herzog";
        userEmail = "ph@flyingcircus.io";
        signKey = "CCA0A0D7BD329C162CB381E9C9B5406DBAF07973";
      };
    };
  };
in {
  flake = {
    darwinConfigurations = {
      work-mac = util.host.mkMac {
        name = "work-mac";
        extraPackages = ps:
          with ps; [
            # fonts
            iosevka-comfy.comfy
            (nerdfonts.override {
              fonts = ["SourceCodePro" "Iosevka"];
            })

            rclone
            osxfuse

            openssl
            openssl.dev

            python310Full
            python310Packages.virtualenv
          ];

        userConfig = hmUsers.philippherzog;
      };
    };

    nixosConfigurations =
      {
        # usb stick iso
        x86-iso = util.iso.mkIso {
          inherit (inputs) nixpkgs;
          hostName = "isoInstall";
          system = "x86_64-linux";
        };

        x86-iso2 = util.host.mkIso rec {
          users = ["nixos"];
          hmUsers = mkHMUsers users;
        };

        # desktop @ home
        gamma = let
          # screw nvidia
          mkHMUsers = users:
            lib.listToAttrs (map
              (user: {
                name = user;
                value = lib.recursiveUpdate hmUsers.${user} {
                  userConfig.wms.hyprland.terminal = "alacritty";
                };
              })
              users);
        in
          util.host.mkWorkstation rec {
            users = ["maelstroem" "nixos" "jaid"];
            hmUsers = mkHMUsers users;
            systemConfig = {
              server.services.openssh.enable = true;

              core.hostName = "gamma";
              core.enableBluetooth = true;

              desktop.enable = true;
              development.enable = true;
              nvidia.enable = true;
              video.managers = ["gnome"];
            };

            extraHostModules = with inputs.nixos-hardware.nixosModules; [
              common-pc
              common-pc-ssd
              common-cpu-amd
              #common-gpu-nvidia
            ];
          };

        # future laptop config
        epsilon = util.host.mkWorkstation rec {
          users = ["nixos"];
          hmUsers = mkHMUsers users;
          systemConfig = {
            server.services.openssh.enable = true;
            core.hostName = "epsilon";

            laptop.enable = true;
            laptop.low_power = true;
          };

          extraHostModules = with inputs.nixos-hardware.nixosModules; [
            common-pc-laptop
            common-pc-laptop-ssd
            common-cpu-intel-cpu-only
            common-cpu-intel-kaby-lake
          ];
        };
      }
      // builtins.mapAttrs
      (servername: services: util.server.mkServer {inherit servername services;})
      net.services;

    # shortcut for building with `nix build`
    systems = builtins.mapAttrs (system: _: self.nixosConfigurations.${system}.config.system.build.toplevel) self.nixosConfigurations;
  };

  perSystem = {system, ...}: {
    #homeConfigurations = lib.mapAttrs (util.user.mkHMUser (util.pkgsFor system)) hmUsers;
    checks = (builtins.mapAttrs (_system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy-rs.lib).${system};
  };

  flake = {
    # requires ifd :/
    setup_packages =
      (lib.mapAttrs' (n: v: {
        name = "${n}-iso";
        value = v.config.system.build.isoImage;
      }) (lib.filterAttrs (_n: v: v.config.system.build ? isoImage) self.nixosConfigurations))
      // (lib.mapAttrs' (n: v: {
        name = "${n}-disko-setup";
        value = v.config.system.build.disko;
      }) (lib.filterAttrs (_n: v: v.config.system.build ? disko) self.nixosConfigurations));
  };
}
