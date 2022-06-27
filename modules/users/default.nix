{ pkgs
, config
, lib
, ...
}:

{
  imports = [
    ./shells

    ./tmux

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
