{ pkgs, config, lib, ... }:

{
  imports = [
    ./neovim
    ./emacs
    ./helix
    ./vscode
  ];
}
