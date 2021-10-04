{ system, pkgs, lib, user, ... }:
with builtins;

rec {
  # set up a vanilla host without any home-manager
  mkHost =
    { name
    , users
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

      imports = ([
        hardware-config
        ../modules/hosts
      ] ++ sys_users) ++ extramods;

      phil = systemConfig;
    };
}
