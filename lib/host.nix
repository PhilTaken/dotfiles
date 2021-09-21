{ system, pkgs, home-manager, lib, user, ... }:
with builtins;
rec {
  # set up a vanilla host without any home-manager
  mkHost =
    { host
    , username ? "nixos"
    , enable_xorg ? false
    , extramods ? [ ]
      #name, NICs, initrdMods, kernelMods, kernelParams, kernelPackage,
      #systemConfig, cpuCores, users, wireless_interfaces ? [], gpuTempSensor ? null,
      #cpuTempSensor ? null
    }:
    let
      hostmod = import (../hosts + "/${host}") {
        inherit inputs pkgs username enable_xorg;
      };
      #networkCfg = listToAttrs (map (n: {
      #name = "${n}";
      #value = { useDHCP = true; };
      #}) NICs);

      #userCfg = {
      #inherit name NICs sytemConfig cpuCores gpuTempSensor cpuTempSensor;
      #};

      #sys_users = (map (u: user.mkSystemUser u) users);
    in
    lib.nixosSystem {
      inherit system pkgs;

      modules = [
        hostmod
      ] ++ extramods;
    };


  # set up a host with a home-manager user
  mkHostWithUser = { host, username ? "nixos", enable_xorg ? false, extramods ? [ ] }:
    let
      usermods = [
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users."${username}" = import (../users + "/${username}/home.nix") {
            inherit pkgs username enable_xorg;
          };
        }
      ] ++ extramods;
    in
    mkHost {
      inherit host username enable_xorg;
      extramods = usermods;
    };
}
