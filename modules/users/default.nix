{ pkgs
, config
, lib
, ...
}:

{
  imports = [
    ./terminals
    ./shells
    ./tmux
    ./zellij
    ./editors

    ./git
    ./ssh
    ./gpg

    ./mail
    ./music
    ./firefox

    ./wms
    ./des
  ];
}
