{ inputs, ... }:
let 
  neovim-nightly-src = { url = "github:neovim/neovim"; flake = false; };
  nvim_overlay = final: prev: {
    neovim-nightly = prev.neovim-unwrapped.overrideAttrs (old: {
      pname = "neovim-nightly";
      version = "master";
      src = inputs.neovim-nightly-src;
      buildInputs = with prev; old.buildInputs ++ [
        tree-sitter
      ];
    });
  };
in nvim_overlay
