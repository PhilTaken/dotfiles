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
    alice.userConfig = {
      leisure.enable = false;

      git = {
        enable = true;
        userName = "Philipp Herzog";
        userEmail = "philipp.herzog@protonmail.com";
        # TODO maybe include pubkey here?
        signKey = "~/.ssh/git.pub";
        signFlavor = "ssh";
      };
    };

    nixos.userConfig = mkConfig {
      work.enable = true;

      # de/wm config
      wms.hyprland.enable = true;
      wms.bars.eww.enable = true;
    };

    maelstroem.userConfig = mkConfig {
      work.enable = true;

      # de/wm config
      wms.hyprland.enable = true;
      wms.bars.eww.enable = true;

      des.gnome.enable = true;
    };

    jaid.userConfig = mkConfig {
      terminals.defaultShell = "zsh";
      des.gnome.enable = true;
    };

    philippherzog.userConfig = {
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
      work-mac = util.host.mkDarwin {
        name = "work-mac";
        extraPackages = ps:
          with ps; [
            # fonts
            iosevka-comfy.comfy
            (nerdfonts.override {fonts = ["SourceCodePro" "Iosevka"];})

            rclone
            osxfuse

            openssl
            openssl.dev

            uv
            python311
          ];

        inherit (hmUsers.philippherzog) userConfig;
      };
    };

    nixosConfigurations =
      {
        # desktop @ home
        gamma = let
          users = ["maelstroem" "nixos" "jaid"];
        in
          util.host.mkNixos (mkHMUsers users) {
            inherit users;
            hostName = "gamma";
            hostModules =
              [
                {
                  phil = {
                    nebula.enable = true;
                    server.services.openssh.enable = true;

                    core.enableBluetooth = true;
                    desktop.enable = true;
                    development.enable = true;
                    nvidia.enable = true;
                    video.managers = ["gnome"];
                  };
                }
              ]
              ++ (with inputs.nixos-hardware.nixosModules; [
                common-pc
                common-pc-ssd
                common-cpu-amd
                #common-gpu-nvidia
              ]);
          };

        # future laptop config
        epsilon = let
          users = ["nixos"];
        in
          util.host.mkNixos (mkHMUsers users) {
            inherit users;
            hostName = "epsilon";

            hostModules = [
              {
                phil = {
                  nebula.enable = true;
                  server.services.openssh.enable = true;

                  laptop.enable = true;
                  laptop.low_power = true;
                };
              }

              inputs.nixos-hardware.nixosModules.common-pc-laptop
              inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
              inputs.nixos-hardware.nixosModules.common-cpu-intel-cpu-only
              inputs.nixos-hardware.nixosModules.common-cpu-intel-kaby-lake
            ];
          };

        zetta = let
          users = ["alice"];
        in
          util.host.mkNixos (mkHMUsers users) {
            system = "aarch64-linux";
            hostName = "zetta";
            inherit users;

            hostModules = [
              {
                phil = {
                  wireguard.enable = false;
                  nebula.enable = false;
                  server.services.openssh.enable = true;
                  video.enable = false;
                };
              }

              {
                # FIXME: connect zetta to nebula to access forgjo via ssh?
                home-manager.users.alice.programs.git.extraConfig.credential.helper = "store";
              }

              ({
                pkgs,
                npins,
                ...
              }: {
                stylix = {
                  image = ../../images/cat-sound.png;
                  base16Scheme = "${npins.base16}/base16/mocha.yaml";

                  fonts = {
                    serif = {
                      package = pkgs.dejavu_fonts;
                      name = "DejaVu Serif";
                    };

                    sansSerif = {
                      package = pkgs.dejavu_fonts;
                      name = "DejaVu Sans";
                    };

                    monospace = {
                      package = pkgs.iosevka-comfy.comfy-duo;
                      name = "Iosevka Comfy";
                    };

                    emoji = {
                      package = pkgs.noto-fonts-emoji;
                      name = "Noto Color Emoji";
                    };
                  };
                };
              })
            ];
          };
      }
      // builtins.mapAttrs
      (hostname: services: (util.server.mkServer services {
        system = net.systems.${hostname} or "x86_64-linux";
        hostName = hostname;
      }))
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
