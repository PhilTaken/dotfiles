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

    #./innernet-client
    #./innernet-server
  ];
}
