{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.neovim;
in
{
  options.phil.neovim = {
    enable = mkOption {
      description = "Enable the neovim module";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    home.sessionVariables = {
      EDITOR = "nvim";
      PAGER = "${pkgs.nvimpager}/bin/nvimpager";
    };

    programs.neovim = {
      enable = true;
      package = pkgs.neovim;
      viAlias = true;
      vimAlias = true;
      withPython3 = true;
      withNodeJs = true;
      extraPython3Packages = (ps: with ps; [ pynvim ]);
      extraPackages = with pkgs; [
        tree-sitter

        sumneko-lua-language-server # lua
        ccls # c/c++
        rnix-lsp # nix
        rust-analyzer # rust
        texlab # latex
        fortls # fortran
        erlang-ls # erlang
        elixir_ls # elixir
        #julia                        # julia

        git # version control
        ripgrep # telescope file finding
        fd # faster find
        gcc # for treesitter

        bottom # custom floaterm
        lazygit # lazy git managment

        neuron-notes # for zettelkasten note-taking
      ] ++ (with pkgs.nodePackages; [
        pyright # python
        typescript-language-server # js / ts
      ]); # ++ (with pkgs.python39Packages; [
      #python-lsp-server
      #python-lsp-black
      #pyls-flake8
      #]);
      extraConfig = ''
        " set langmap=qq,dw,re,wr,bt,jy,fu,ui,po,\\;p,aa,ss,hd,tf,gg,yh,nj,ek,ol,i\\;,zz,xx,mc,cv,vb,kn,lm,QQ,DW,RE,WR,BT,JY,FU,UI,PO,:P,AA,SS,HD,TF,GG,YH,NJ,EK,OL,I:,ZZ,XX,MC,CV,VB,KN,LM
        luafile ~/.config/nvim/init_.lua
      '';
    };

    home.packages = with pkgs; [
      visidata
      neovim-remote
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
