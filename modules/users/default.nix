{ pkgs, config, lib, ... }:

{
  imports = [
    ./firefox
    ./git
    ./gpg
    ./i3
    ./kde
    ./mail
    ./music
    ./neovim
    ./ssh
    ./sway
    ./zsh_full
  ];
}
