{
  user,
  inputs,
  systemmodules,
  pkgsFor,
  flake,
}: let
  inherit (inputs) nixpkgs;
  inherit (nixpkgs) lib;
  npins = import ../npins;
in rec {
  mkHost = {
    users,
    systemConfig,
    hmUsers ? {},
    extraimports ? [],
    extraHostModules ? [],
    system ? "x86_64-linux",
    lib ? inputs.nixpkgs.lib,
    pkgs ? pkgsFor system,
    hardware-config ? (import ../machines/${systemConfig.core.hostName}),
  }: let
    raw_users =
      lib.zipListsWith
      (name: uid:
        if builtins.isAttrs name
        then (lib.mergeAttrs {inherit uid;} name)
        else {inherit name uid;})
      users
      (lib.range 1000 (builtins.length users + 1000));

    # TODO: pls pls pls improve this
    part = builtins.partition (raw_user: builtins.elem raw_user.name ["nixos" "maelstroem" "alice"]) raw_users;
    sys_users = (map user.mkSystemUser part.right) ++ (map user.mkGuestUser part.wrong);
    net = import ../network.nix {};
  in
    lib.nixosSystem {
      inherit system pkgs;
      specialArgs = {inherit inputs net flake npins;};

      modules =
        [
          {
            imports =
              [
                hardware-config
                ../modules/hosts
                {i18n.supportedLocales = lib.mkForce ["en_US.UTF-8/UTF-8" "de_DE.UTF-8/UTF-8"];}
              ]
              ++ sys_users
              ++ extraimports;

            phil = systemConfig;

            nix.registry.nixpkgs.flake = nixpkgs;

            nixpkgs.overlays = [
              inputs.nixpkgs-wayland.overlay
              inputs.neovim-nightly-overlay.overlay
            ];

            sops = {
              defaultSopsFile = ../sops/sops.yaml;
              age = {
                keyFile = "/var/lib/sops-nix/key.txt";
                generateKey = true;
              };
            };

            system.nixos.label = "g${inputs.self.shortRev or "shortRev-not-set"}";

            programs.fish.enable = true;

            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {inherit inputs net npins;};
              users = lib.mapAttrs (user.mkConfig pkgs) hmUsers;
            };
          }
        ]
        ++ (systemmodules.${system} or systemmodules.default)
        ++ extraHostModules;
    };

  mkMac = {
    name,
    userConfig ? {},
    extraPackages ? _: {},
    username ? "philippherzog",
    system ? "aarch64-darwin",
    lib ? inputs.nixpkgs.lib,
    pkgs ? pkgsFor system,
  }:
    inputs.darwin.lib.darwinSystem {
      inherit system pkgs;
      specialArgs = {inherit inputs flake;};

      modules = [
        inputs.home-manager.darwinModule
        inputs.stylix.darwinModules.stylix

        (../machines + "/${name}")
        (../machines + "/${name}/${username}.nix")

        {
          stylix = {
            image = ../images/vortex.png;
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
                #package = pkgs.dejavu_fonts;
                #name = "DejaVu Sans Mono";
                package = pkgs.iosevka-comfy.comfy-duo;
                name = "Iosevka Comfy";
              };

              emoji = {
                package = pkgs.noto-fonts-emoji;
                name = "Noto Color Emoji";
              };
            };
          };
          home-manager.users.${username} = {
            imports = [
              (user.mkConfig pkgs username {
                inherit userConfig extraPackages;
                stateVersion = "22.05";
                homeDirectory = "/Users/${username}";
              })
            ];
          };

          nix = {
            registry.nixpkgs.flake = nixpkgs;
            settings.trusted-users = [username];
            extraOptions = ''
              auto-optimise-store = false
            '';
          };

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = {inherit inputs npins;};
          };
        }
      ];
    };

  mkIso = inpargs: let
    args =
      lib.recursiveUpdate {
        systemConfig = {
          wireguard.enable = false;
          server.services.openssh.enable = true;
          core.hostName = "iso";
        };

        hardware-config = {};
        extraHostModules = [
          inputs.stylix.nixosModules.stylix
          "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-base.nix"
          {
            sops.age = lib.mkForce {
              keyFile = null;
              generateKey = false;
            };

            sops.gnupg = {
              home = "/run/gpghome";
              sshKeyPaths = [];
            };
          }
        ];
      }
      inpargs;
  in
    mkHost args;

  mkWorkstation = inpargs: let
    args =
      (lib.recursiveUpdate {
          systemConfig = {
            wireguard.enable = true;
            nebula.enable = true;
            #mullvad.enable = true;
            workstation.enable = true;
          };
        }
        inpargs)
      // {
        extraHostModules =
          (inpargs.extraHostModules or [])
          ++ [
            inputs.stylix.nixosModules.stylix
            ({...}: {
              #sops.secrets.key.sopsFile = ../sops/nebula.yaml;
              #sops.secrets.ca.sopsFile = ../sops/nebula.yaml;

              environment.systemPackages = [
                # WIP
                #(pkgs.writeShellScriptBin "nebsign" ''
                #${pkgs.nebula}/bin/nebula-cert sign -ca-crt ${config.sops.secrets.ca.path} -ca-key ${config.sops.secrets.key.path} "$@"
                #cp ${config.sops.secrets.ca.path} ./ca.pem
                #'')
              ];
            })
          ];
      };
  in
    mkHost args;
}
