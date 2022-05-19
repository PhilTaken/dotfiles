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

    ./editors/neovim
    ./editors/spacemacs

    ./wms/sway
    ./wms/i3

    ./wms/bars/polybar
    ./wms/bars/eww

    ./des/kde
    ./des/gnome
  ];
}
