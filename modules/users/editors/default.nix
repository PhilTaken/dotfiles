{ pkgs, config, lib, ... }:

{
  imports = [
    ./neovim
    ./spacemacs
    ./helix
  ];
}
