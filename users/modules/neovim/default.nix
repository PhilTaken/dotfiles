{ pkgs, ... }:
{
  programs.neovim = let 
    neovim-config-file = ./init-nightly.vim;
  in {
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
      vim-airline
      vim-airline-themes
      vim-pandoc
      vim-pandoc-syntax
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
    extraConfig = builtins.readFile neovim-config-file;
    extraPython3Packages =  (ps: with ps; [ pynvim python-language-server ]);
  };
}
