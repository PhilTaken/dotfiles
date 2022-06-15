{ pkgs, config, lib, nixpkgs, ... }:

{
  imports = [
    (import ./core { inherit pkgs config lib nixpkgs; })

    ./yubikey

    ./laptop
    ./sound
    ./video
    ./desktop
    ./nvidia

    ./server
    ./dns

    ./development
    ./fileshare
    ./backup

    ./wireguard
    ./nebula
    ./mullvad
  ];
}
