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

    #./innernet-client
    #./innernet-server
  ];
}
