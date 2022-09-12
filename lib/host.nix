{ system
, pkgs
, lib
, user
, extramodules ? [ ]
, nixpkgs
, inputs
, ...
}:
with builtins;

let
  net = import ../network.nix { };
in
rec {
  # set up a vanilla host without any home-manager
  mkHost =
    { users
    , systemConfig
    , wireless_interfaces ? [ ]
    , extraimports ? [ ]
    , hmConfigs ? [ ]
    , hardware-config ? (import ../machines/${systemConfig.core.hostName})
    , extraHostModules ? [ ]
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
          imports = [
            hardware-config
            ../modules/hosts
            { i18n.supportedLocales = lib.mkForce [ "en_US.UTF-8/UTF-8" "de_DE.UTF-8/UTF-8" ]; }
          ] ++ sys_users ++ extraimports;

          phil = systemConfig;

          nix.registry.nixpkgs.flake = nixpkgs;

          sops.defaultSopsFile = ../sops/sops.yaml;
          sops.age.keyFile = "/var/lib/sops-nix/key.txt";
          sops.age.generateKey = true;

          system.nixos.label = "g${inputs.self.shortRev or "shortRev-not-set"}";
          nixpkgs.overlays = [
            inputs.nixpkgs-wayland.overlay
          ];
        }
      ] ++ extramodules ++ hmConfigs ++ extraHostModules;
    };

  mkWorkstation = inpargs:
    let
      args = inpargs // {
        systemConfig = lib.mergeAttrs
          {
            wireguard.enable = true;
            nebula.enable = true;
            server.services.telegraf.enable = false;
            mullvad.enable = true;
            dns.nameserver = builtins.head (builtins.attrNames (lib.filterAttrs (name: value: lib.hasInfix "unbound" (lib.concatStrings value)) net.services));
            workstation.enable = true;
          }
          inpargs.systemConfig;
        extraHostModules = (inpargs.extraHostModules or [ ]) ++ [
          ({ config, ... }:
            let
              sopsConfig = {
                group = "wheel";
                sopsFile = ../sops/nebula.yaml;
              };
            in
            {
              sops.secrets.key.sopsFile = ../sops/nebula.yaml;
              sops.secrets.ca.sopsFile = ../sops/nebula.yaml;

              environment.systemPackages = [
                (pkgs.writeShellScriptBin "nebsign" ''
                  ${pkgs.nebula}/bin/nebula-cert sign -ca-crt ${config.sops.secrets.ca.path} -ca-key ${config.sops.secrets.key.path} "$@"
                  cp ${config.sops.secrets.ca.path} ./ca.pem
                '')
              ];
            })
        ];
      };
    in
    mkHost args;
}
