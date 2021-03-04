{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly;
    viAlias = true;
    vimAlias = true;
    withPython3 = true;
    withNodeJs = true;
    plugins = with pkgs.vimPlugins; [
      vim-fugitive
      vim-gitgutter
      vim-rooter
      vim-startify
      vim-surround
      vim-speeddating
      vim-snippets
      targets-vim
      echodoc-vim
      nerdcommenter
      auto-pairs
      vim-tmux-navigator

      galaxyline-nvim

      vim-pandoc
      vim-pandoc-syntax
      vimwiki
      vim-nix
      ayu-vim
      ultisnips

      nvim-lspconfig
      lsp_extensions-nvim
      nvim-treesitter
      popup-nvim
      plenary-nvim
      telescope-nvim
      nvim-web-devicons
      completion-nvim
      completion-buffers
      completion-treesitter
    ];
    extraPython3Packages = (ps: with ps; [
      pynvim
    ]);
    extraPackages = with pkgs; [
      sumneko-lua-language-server   # lua
      ccls                          # c/c++
      rnix-lsp                      # nix
      nodePackages.pyright          # python
      rust-analyzer                 # rust
      texlab                        # latex
      fortls                        # fortran
      git                           # version control
    ];
    extraConfig = builtins.readFile ./init-nightly.vim;
  };

  #xdg.configFile."nvim/init.vim".source = ./init-nightly.vim;
  #xdg.configFile."nvim/init.lua".source = ./init.lua;

  xdg.configFile."nvim/lua/" = {
    source = ./lua;
    recursive = true;
  };
}
