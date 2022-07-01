{ pkgs
, config
, lib
, ...
}:

{
  imports = [
    ./shells

    ./tmux
    ./zellij

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
