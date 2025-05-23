{
  self,
  inputs,
  ...
}: let
  inherit (inputs.nixpkgs) lib;

  util = import ../../lib {inherit inputs self;};
  net = (lib.evalModules {modules = [../../network.nix];}).config.phil.network;

  mkHMUsers = users: lib.listToAttrs (map (user: lib.nameValuePair user hmUsers.${user}) users);

  hmUsers = let
    mkConfig = lib.recursiveUpdate {
      ssh.enable = true;
      music.enable = true;
    };
  in {
    alice.userConfig = {
      headless = true;
      music.enable = false;

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
      des.gnome.enable = true;

      wms.hyprland.enable = true;
      wms.bars.eww.enable = true;

      gpg.enable = true;

      browsers = {
        enable = true;
        firefox.enable = true;
        firefox.wayland = true;
      };
    };

    maelstroem.userConfig = mkConfig {
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
        ts = true;
        python = true;
      };

      shells.fish.enable = true;
      gpg.enable = true;

      zellij.enable = false;
      git.enable = true;
    };
  };
in {
  flake = {
    darwinConfigurations = {
      work-mac = util.host.mkDarwin {
        name = "work-mac";
        inherit (hmUsers.philippherzog) userConfig;
      };

      work-mac-new = util.host.mkDarwin {
        name = "work-mac-new";
        inherit (hmUsers.philippherzog) userConfig;
        system = "x86_64-darwin";
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
                    # server.services.openssh.enable = true;

                    core.enableBluetooth = true;
                    desktop.enable = true;
                    development.enable = true;
                    nvidia.enable = true;
                    video.managers = [
                      "gnome"
                      #"cosmic"
                    ];
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
                  server.services.openssh.enable = true;

                  laptop.enable = true;
                  laptop.low_power = true;
                };
              }

              inputs.nixos-hardware.nixosModules.common-pc-laptop
              inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
              inputs.nixos-hardware.nixosModules.common-cpu-intel-cpu-only
              inputs.nixos-hardware.nixosModules.common-gpu-intel-kaby-lake
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
                  server.services.openssh.enable = true;
                  wireguard.enable = false;
                  video.enable = false;
                  yubikey.enable = false;
                };
              }

              ({lib, ...}: {
                # FIXME: connect zetta to nebula to access forgjo via ssh?
                home-manager.users.alice.programs.git.extraConfig.credential.helper = "store";

                # this somehow breaks deployments
                home-manager.users.alice.programs.carapace.enable = lib.mkForce false;

                # disable to prevent inferring dns from vm host
                services.resolved.enable = lib.mkForce false;
              })

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
      (nodename: nodeconfig: (util.server.mkServer nodeconfig.services {
        inherit (nodeconfig) system;
        hostName = nodename;
      }))
      net.nodes;

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
