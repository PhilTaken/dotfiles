{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.editors.neovim;
in
{
  options.phil.editors.neovim = {
    enable = mkOption {
      description = "Enable the neovim module";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf (cfg.enable) {
    home.sessionVariables = {
      EDITOR = "nvim";
      #PAGER = "${pkgs.nvimpager}/bin/nvimpager";
    };

    programs.neovim = {
      enable = true;
      package = pkgs.neovim-unwrapped;
      viAlias = true;
      vimAlias = true;
      withPython3 = true;
      withNodeJs = true;
      extraPython3Packages = (ps: with ps; [ pynvim ]);
      extraPackages = with pkgs; [
        gcc11
        gcc-unwrapped

        tree-sitter

        sumneko-lua-language-server # lua
        ccls # c/c++
        rnix-lsp # nix
        rust-analyzer # rust
        texlab # latex
        fortls # fortran
        erlang-ls # erlang
        elixir_ls # elixir
        clojure-lsp # clojure
        haskell-language-server # haskell

        git # version control
        ripgrep # telescope file finding
        fd # faster find
        gcc # for treesitter

        bottom # custom floaterm
        lazygit # lazy git managment

        neuron-notes # for zettelkasten note-taking

        sqlite # for sqlite.lua
        universal-ctags # ctags for anything

        inetutils # remote editing
      ] ++ (with pkgs.nodePackages; [
        #pyright # python
        typescript-language-server # js / ts
      ]) ++ (with pkgs.python39Packages; [
        python-lsp-server
        python-lsp-black
        pyls-isort
        hy
      ]);

      extraConfig = ''
        " set langmap=qq,dw,re,wr,bt,jy,fu,ui,po,\\;p,aa,ss,hd,tf,gg,yh,nj,ek,ol,i\\;,zz,xx,mc,cv,vb,kn,lm,QQ,DW,RE,WR,BT,JY,FU,UI,PO,:P,AA,SS,HD,TF,GG,YH,NJ,EK,OL,I:,ZZ,XX,MC,CV,VB,KN,LM
        let g:sqlite_clib_path = '${pkgs.sqlite.out}/lib/libsqlite3.so'"
        luafile ~/.config/nvim/init_.lua

        " write to undofile in undodir
        set undodir=${config.xdg.dataHome}
        set undofile
      '';
    };

    home.packages = with pkgs; [
      visidata
      #neovim-remote
      (writeShellScriptBin "neovide-mg" "exec ${pkgs.neovide}/bin/neovide --multigrid")
      neovide
    ];

    xdg.configFile."nvim/init_.lua".source = ./init.lua;
    xdg.configFile."goneovim/settings.toml".source = ./goneovim_settings.toml;

    home.file.".visidatarc".source = ./visidatarc;

    xdg.configFile."nvim/lua/" = {
      source = ./lua;
      recursive = true;
    };
  };
}
