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
    , hardware-config ? ({ ... }: { })
    , systemConfig
    , username ? "nixos"
    , wireless_interfaces ? [ ]
    , extraimports ? [ ]
    , hmConfigs ? []
    }:
    let
      sys_users = (map (u: user.mkSystemUser u) users);
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
      ] ++ hmConfigs ++ extramodules;
    };
}
