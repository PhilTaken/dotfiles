{ system, pkgs, lib, user, sops-nix, ... }:
with builtins;

rec {
  # set up a vanilla host without any home-manager
  mkHost =
    { users
    , hardware-config
    , systemConfig
    , username ? "nixos"
    , wireless_interfaces ? [ ]
    , extramods ? [ ]
      #name, initrdMods, kernelMods, kernelParams, kernelPackage,
      #systemConfig
    }:
    let
      sys_users = (map (u: user.mkSystemUser u) users);
    in
    lib.nixosSystem {
      inherit system pkgs;

      modules = [
        sops-nix
        {
          imports = ([
            hardware-config
            ../modules/hosts
          ] ++ sys_users) ++ extramods;

          phil = systemConfig;

          sops.defaultSopsFile = ../secret/sops.yaml;
          sops.secrets."mullvad/privateKey" = {};
        }
      ];
    };
}
