{ inputs, ... }:
let 
  nvim_overlay = final: prev: {
    neovim = prev.neovim-unwrapped.overrideAttrs (old: {
      pname = "neovim-nightly";
      version = "master";
      src = inputs.neovim-nightly-src;
      buildInputs = with prev; old.buildInputs ++ [
        tree-sitter
      ];
    });
  };
in nvim_overlay
