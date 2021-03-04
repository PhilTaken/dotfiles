{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly;
    viAlias = true;
    vimAlias = true;
    withPython3 = true;
    withNodeJs = true;
    extraPython3Packages = (ps: with ps; [ pynvim ]);
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
    extraConfig = ''
      set langmap=qq,dw,re,wr,bt,jy,fu,ui,po,\\;p,aa,ss,hd,tf,gg,yh,nj,ek,ol,i\\;,zz,xx,mc,cv,vb,kn,lm,QQ,DW,RE,WR,BT,JY,FU,UI,PO,:P,AA,SS,HD,TF,GG,YH,NJ,EK,OL,I:,ZZ,XX,MC,CV,VB,KN,LM
      luafile ~/.config/nvim/init_.lua
    '';
  };

  #xdg.configFile."nvim/init.vim".source = ./init-nightly.vim;
  xdg.configFile."nvim/init_.lua".source = ./init.lua;

  xdg.configFile."nvim/lua/" = {
    source = ./lua;
    recursive = true;
  };
}
