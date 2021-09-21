{ pkgs, config, lib, ...}:

{
  imports = [
    ./core
    ./desktop
    ./laptop
    ./innernet-client
    ./innernet-server
    ./webapps
    ./laptop
  ];
}
