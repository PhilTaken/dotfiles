{ pkgs, config, lib, ... }:

{
  imports = [
    ./core
    ./laptop
    ./sound
    ./video
    ./yubikey
    ./server
    ./desktop
    ./backup
    ./nvidia
    ./wireguard
    ./fileshare
    ./development
    ./mullvad
    ./arm
    ./nebula

    ./dns
    #./innernet-client
    #./innernet-server
  ];
}
