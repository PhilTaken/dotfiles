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

    #./desktop
    #./innernet-client
    #./innernet-server
  ];
}
