{ pkgs, config, lib, ... }:

{
  imports = [
    ./core
    ./laptop
    ./sound
    ./video
    ./yubikey
    ./server
    ./webapps
    ./desktop
    ./backup
    ./nvidia
    ./wireguard

    #./innernet-client
    #./innernet-server
  ];
}
