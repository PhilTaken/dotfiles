" leader
let mapleader="\<Space>"

" colorscheme
set termguicolors
let ayucolor="mirage"
try
    colorscheme ayu
catch /^Vim\%((\a\+)\)\=:E185/
    "colorscheme koehler
endtry

"---------------------------
"           sets
" ---------------------------
" turn backup off partially
set nobackup
set noswapfile
set nowb
set nospell

" completion settings
set completeopt=menuone,noinsert,noselect
set shortmess+=c

" line numbers
"set number
"set relativenumber

" case insensitive/smart searching
set ignorecase
set smartcase
set incsearch
set hlsearch
" autoindent inside of bracket
set autoindent
set copyindent
set nowrap
set backspace=indent,eol,start
set shiftround
set smarttab
set pastetoggle=<F3>
set laststatus=2
set timeout
set timeoutlen=300
set ttimeoutlen=0

" ---------------------------
"           lets
" ---------------------------

" workman layout setting
"let g:workman_normal_qwerty = 1
set langmap=qq,dw,re,wr,bt,jy,fu,ui,po,\\;p,aa,ss,hd,tf,gg,yh,nj,ek,ol,i\\;,zz,xx,mc,cv,vb,kn,lm,QQ,DW,RE,WR,BT,JY,FU,UI,PO,:P,AA,SS,HD,TF,GG,YH,NJ,EK,OL,I:,ZZ,XX,MC,CV,VB,KN,LM

"" ------------------------------------
""             mappings 
"" ------------------------------------

nmap <Tab> :bn<CR>
nmap <S-Tab> :bp<CR>
nmap <Leader><Tab> :bd<CR>

nnoremap <A-a> <C-a>
nnoremap <A-x> <C-x>

" clear after search
nnoremap <Leader><Leader> :noh<CR>

" search in visual
vnoremap / y/<C-R>"<CR>
