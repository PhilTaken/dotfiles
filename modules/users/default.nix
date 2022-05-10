{ pkgs, config, lib, ... }:

{
  imports = [
    ./firefox
    ./git
    ./gpg
    ./i3
    ./kde
    ./gnome
    ./mail
    ./music
    ./neovim
    ./ssh
    ./sway
    ./zsh_full
    ./spacemacs
  ];
}
