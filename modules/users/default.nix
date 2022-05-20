{ pkgs, config, lib, ... }:

{
  imports = [
    ./zsh_full
    ./git
    ./ssh
    ./gpg

    ./mail
    ./music
    ./firefox

    ./wms
    ./des

    ./editors
  ];
}
