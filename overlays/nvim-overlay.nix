{ neovim-nightly-src, ... }:
let 
  nvim_overlay = final: prev: {
    neovim = prev.neovim-unwrapped.overrideAttrs (old: {
      pname = "neovim-nightly";
      version = "master";
      src = neovim-nightly-src;
      buildInputs = with prev; old.buildInputs ++ [
        tree-sitter
      ];
    });
  };
in nvim_overlay
