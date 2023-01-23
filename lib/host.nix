{ user
, inputs
, systemmodules
, pkgsFor
}:
let
  inherit (inputs) nixpkgs;
  inherit (nixpkgs) lib;
in
rec {
  mkHost =
    { users
    , systemConfig
    , wireless_interfaces ? [ ]
    , hmUsers ? { }
    , extraimports ? [ ]
    , extraHostModules ? [ ]
    , system ? "x86_64-linux"
    , lib ? inputs.nixpkgs.lib
    , pkgs ? pkgsFor system
    , hardware-config ? (import ../machines/${systemConfig.core.hostName})
    }:
    let
      raw_users = lib.zipListsWith
        (name: uid:
          if builtins.isAttrs name then
            (lib.mergeAttrs { inherit uid; } name)
          else
            { inherit name uid; })
        users
        (lib.range 1000 (builtins.length users + 1000));

      part = builtins.partition (raw_user: builtins.elem raw_user.name [ "nixos" "maelstroem" ]) raw_users;
      sys_users = (map user.mkSystemUser part.right) ++ (map user.mkGuestUser part.wrong);
    in
    lib.nixosSystem {
      inherit system pkgs;

      modules = [
        {
          _module.args = { inherit inputs; };
          imports = [
            hardware-config
            ../modules/hosts
            { i18n.supportedLocales = lib.mkForce [ "en_US.UTF-8/UTF-8" "de_DE.UTF-8/UTF-8" ]; }
          ] ++ sys_users ++ extraimports;

          phil = systemConfig;

          nix.registry.nixpkgs.flake = nixpkgs;
          nixpkgs.overlays = [
            inputs.nixpkgs-wayland.overlay
          ];

          sops.defaultSopsFile = ../sops/sops.yaml;
          sops.age.keyFile = "/var/lib/sops-nix/key.txt";
          sops.age.generateKey = true;

          system.nixos.label = "g${inputs.self.shortRev or "shortRev-not-set"}";

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = { inherit inputs; };
            users = lib.mapAttrs (user.mkConfig pkgs) hmUsers;
          };
        }
      ] ++ (systemmodules.${system} or systemmodules.default) ++ extraHostModules;
    };

  mkWorkstation = inpargs:
    let
      args = lib.recursiveUpdate inpargs {
        systemConfig = {
          wireguard.enable = true;
          nebula.enable = true;
          mullvad.enable = true;
          workstation.enable = true;
        };
        extraHostModules = (inpargs.extraHostModules or [ ]) ++ [
          ({ config, ... }: {
            sops.secrets.key.sopsFile = ../sops/nebula.yaml;
            sops.secrets.ca.sopsFile = ../sops/nebula.yaml;

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
