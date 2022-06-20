{ system
, pkgs
, lib
, user
, extramodules ? [ ]
, nixpkgs
, ...
}:
with builtins;

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

      contains = val: builtins.foldl' (accum: elem: elem == val || accum) false;
      part = builtins.partition (lib.flip contains ["nixos" "maelstroem"]) raw_users;
      sys_users = map user.mkSystemUser part.right;
      guest_users = map user.mkGuestUser part.wrong;
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
}
