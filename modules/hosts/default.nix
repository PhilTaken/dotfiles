{ pkgs, config, lib, ... }:

{
  imports = [
    ./core

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
    ./arm

    ./wireguard
    ./mullvad
    ./nebula
  ];
}
