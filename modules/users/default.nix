{ pkgs, config, lib, ...}:

{
  imports = [
    ./firefox
    ./git
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
