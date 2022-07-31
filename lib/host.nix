{ system
, pkgs
, lib
, user
, extramodules ? [ ]
, nixpkgs
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
          ] ++ sys_users ++ extraimports;

          phil = systemConfig;

          nix.registry.nixpkgs.flake = nixpkgs;

          sops.defaultSopsFile = ../sops/sops.yaml;
          sops.age.keyFile = "/var/lib/sops-nix/key.txt";
          sops.age.generateKey = true;
        }
      ] ++ extramodules ++ hmConfigs;
    };

  mkWorkstation = inpargs:
    let
      args = lib.mergeAttrs {
        systemConfig = lib.mergeAttrs {
          wireguard.enable = true;
          nebula.enable = true;
          server.services.telegraf.enable = false;
          mullvad.enable = true;
          dns.nameserver = builtins.head (builtins.attrNames (lib.filterAttrs (name: value: lib.hasInfix "unbound" (lib.concatStrings value)) net.services));
        } inpargs.systemConfig;
      } inpargs;
    in mkHost args;
}
