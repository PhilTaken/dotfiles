{ system, pkgs, lib, user, extramodules ? [ ], ... }:
with builtins;

rec {
  # set up a vanilla host without any home-manager
  mkHost =
    { users
    , hardware-config
    , systemConfig
    , username ? "nixos"
    , wireless_interfaces ? [ ]
    , extraimports ? [ ]
    }:
    let
      sys_users = (map (u: user.mkSystemUser u) users);
    in
    lib.nixosSystem {
      inherit system pkgs;

      modules = [
        {
          imports = ([
            hardware-config
            ../modules/hosts
          ] ++ sys_users) ++ extraimports;

          phil = systemConfig;

          sops.defaultSopsFile = ../secrets/sops.yaml;
          sops.age.keyFile = "/var/lib/sops-nix/key.txt";
          sops.age.generateKey = true;

          # secrets
          sops.secrets.mullvad-privateKey = { };
          sops.secrets.spotify-username = { };
          sops.secrets.spotify-password = { };
          sops.secrets.vaultwarden-adminToken = { };
          sops.secrets.vaultwarden-yubicoClientId = { };
          sops.secrets.vaultwarden-yubicoSecretKey = { };
        }
      ] ++ extramodules;
    };
}
