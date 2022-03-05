{ pkgs
, config
, lib
, ...
}:

{
  imports = [
    ./server.nix
    ./apps.nix
  ];
}
