{
  user,
  inputs,
  flake,
  overlays,
}:
let
  npins = import ../npins;
  nixpkgs = {
    inherit overlays;
    config.allowUnfree = true;
  };
  netlib = import ../lib/network.nix;

  # extra args for nixos/darwin system modules
  specialArgs = { inherit inputs flake npins; };
  # extra args for home-manager modules
  extraSpecialArgs = { inherit inputs npins; };
in
rec {
  mkBase =
    defaultModules:
    {
      users ? [ "nixos" ],
      hostName,
      hostModules ? [ ],
      hardware-config ? (import ../machines/${hostName}),
      system ? "x86_64-linux",
    }:
    let
      inherit (inputs.nixpkgs) lib;

      # TODO: pls improve this
      raw_users = lib.zipListsWith (
        name: uid:
        if builtins.isAttrs name then (lib.mergeAttrs { inherit uid; } name) else { inherit name uid; }
      ) users (lib.range 1000 (builtins.length users + 1000));
      part = builtins.partition (
        raw_user:
        builtins.elem raw_user.name [
          "nixos"
          "maelstroem"
          "alice"
        ]
      ) raw_users;
      sys_users = (map user.mkSystemUser part.right) ++ (map user.mkGuestUser part.wrong);

      modules =
        defaultModules
        ++ hostModules
        ++ [
          (
            {
              lib,
              config,
              ...
            }:
            {
              _module.args.netlib = netlib config lib;

              imports = [
                ../modules/hosts
                hardware-config
                ../network.nix
              ]
              ++ sys_users;

              nix.registry.nixpkgs.flake = inputs.nixpkgs;
              nixpkgs.overlays = [
                inputs.nixpkgs-wayland.overlay
              ]
              ++ overlays;

              sops = {
                defaultSopsFile = ../sops/sops.yaml;
                age = {
                  keyFile = "/var/lib/sops-nix/key.txt";
                  generateKey = false;
                };
              };

              programs.fish.enable = true;
              i18n.supportedLocales = [
                "en_US.UTF-8/UTF-8"
                "de_DE.UTF-8/UTF-8"
              ];

              phil.core.hostName = lib.mkDefault hostName;
              system.nixos.label = "g${inputs.self.shortRev or "shortRev-not-set"}";
            }
          )

          inputs.sops-nix-src.nixosModules.sops
          inputs.disko.nixosModules.disko
        ];
    in
    lib.nixosSystem {
      inherit system modules specialArgs;
    };

  mkNixos =
    hmUsers:
    mkBase [
      inputs.stylix.nixosModules.stylix
      inputs.home-manager.nixosModules.home-manager
      #inputs.hyprland.nixosModules.default

      (
        {
          pkgs,
          lib,
          ...
        }:
        {
          nixpkgs = nixpkgs // {
            overlays = nixpkgs.overlays ++ [
              #inputs.hyprland.overlays.default
              #inputs.xdg-desktop-hyprland.overlays.default
            ];
          };
          home-manager = {
            inherit extraSpecialArgs;
            useGlobalPkgs = true;
            useUserPackages = true;
            users = lib.mapAttrs (user.mkConfig pkgs) hmUsers;
          };
        }
      )
    ];

  mkDarwin =
    {
      name,
      userConfig ? { },
      extraPackages ? _: [ ],
      username ? "philippherzog",
      system ? "aarch64-darwin",
      lib ? inputs.nixpkgs.lib,
      hardware-config ? (import ../machines/${name}),
    }:
    inputs.darwin.lib.darwinSystem {
      inherit system specialArgs;

      modules = [
        hardware-config
        #inputs.lix-module.nixosModules.default
        inputs.lix-module.nixosModules.lixFromNixpkgs

        (
          {
            pkgs,
            config,
            lib,
            ...
          }:
          {
            _module.args.netlib = netlib config lib;

            inherit nixpkgs;
            nix = {
              registry.nixpkgs.flake = inputs.nixpkgs;
              settings.trusted-users = [ username ];

              # currently broken on mac?
              extraOptions = ''
                auto-optimise-store = false
              '';
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

            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              inherit extraSpecialArgs;
            };
          }
        )

        inputs.home-manager.darwinModules.default
        inputs.stylix.darwinModules.stylix
      ];
    };
}
