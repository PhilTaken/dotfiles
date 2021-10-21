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

    #./innernet-client
    #./innernet-server
  ];
}
