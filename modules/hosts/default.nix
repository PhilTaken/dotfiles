{ pkgs, config, lib, nixpkgs, ... }:

{
  imports = [
    (import ./core { inherit pkgs config lib nixpkgs; })

    ./yubikey

    ./sound
    ./video
    ./nvidia

    ./workstation
    ./laptop

    ./server

    ./development
    ./fileshare
    ./backup

    ./dns
    ./wireguard
    ./nebula
    ./mullvad
  ];
}
