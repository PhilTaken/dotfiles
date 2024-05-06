{
  user,
  inputs,
  pkgsFor,
  flake,
}: let
  npins = import ../npins;
  net = import ../network.nix {};
in rec {
  mkBase = defaultModules: {
    users ? ["nixos"],
    hostName,
    hostModules ? [],
    hardware-config ? (import ../machines/${hostName}),
    system ? "x86_64-linux",
    pkgs ? pkgsFor system,
  }: let
    inherit (inputs.nixpkgs) lib;

    # TODO: pls pls pls improve this
    raw_users =
      lib.zipListsWith
      (name: uid:
        if builtins.isAttrs name
        then (lib.mergeAttrs {inherit uid;} name)
        else {inherit name uid;})
      users
      (lib.range 1000 (builtins.length users + 1000));
    part = builtins.partition (raw_user: builtins.elem raw_user.name ["nixos" "maelstroem" "alice"]) raw_users;
    sys_users = (map user.mkSystemUser part.right) ++ (map user.mkGuestUser part.wrong);

    modules =
      defaultModules
      ++ hostModules
      ++ [
        {
          imports = [../modules/hosts hardware-config] ++ sys_users;
          phil.core.hostName = lib.mkDefault hostName;

          programs.fish.enable = true;

          nix.registry.nixpkgs.flake = inputs.nixpkgs;
          i18n.supportedLocales = ["en_US.UTF-8/UTF-8" "de_DE.UTF-8/UTF-8"];

          nixpkgs.overlays = [
            inputs.nixpkgs-wayland.overlay
            inputs.neovim-nightly-overlay.overlay
          ];

          sops = {
            defaultSopsFile = ../sops/sops.yaml;
            age = {
              keyFile = "/var/lib/sops-nix/key.txt";
              generateKey = false;
            };
          };

          system.nixos.label = "g${inputs.self.shortRev or "shortRev-not-set"}";
        }

        inputs.sops-nix-src.nixosModules.sops
        inputs.disko.nixosModules.disko
      ];
  in
    lib.nixosSystem {
      inherit system pkgs modules;
      specialArgs = {inherit inputs net flake npins;};
    };

  mkNixos = hmUsers:
    mkBase [
      inputs.stylix.nixosModules.stylix
      inputs.home-manager.nixosModules.home-manager
      inputs.hyprland.nixosModules.default
      inputs.lix-module.nixosModules.default
      ({
        pkgs,
        lib,
        ...
      }: {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {inherit inputs net npins;};
          users = lib.mapAttrs (user.mkConfig pkgs) hmUsers;
        };
      })
    ];

  mkDarwin = {
    name,
    userConfig ? {},
    extraPackages ? _: {},
    username ? "philippherzog",
    system ? "aarch64-darwin",
    lib ? inputs.nixpkgs.lib,
    pkgs ? pkgsFor system,
    hardware-config ? (import ../machines/${name}),
  }:
    inputs.darwin.lib.darwinSystem {
      inherit system pkgs;
      specialArgs = {inherit inputs flake npins;};

      modules = [
        hardware-config
        inputs.lix-module.nixosModules.default

        {
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
            registry.nixpkgs.flake = inputs.nixpkgs;
            settings.trusted-users = [username];

            # currently broken on mac?
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

        inputs.home-manager.darwinModule
        inputs.stylix.darwinModules.stylix
      ];
    };
}
