" leader
let mapleader="\<Space>"

" colorscheme
set termguicolors
let ayucolor="mirage"
try
    colorscheme ayu
catch /^Vim\%((\a\+)\)\=:E185/
    colorscheme koehler
endtry

"---------------------------
"           sets
" ---------------------------

set formatoptions+=j
set history=1000
set undolevels=1000
set wildignore=*.swp,*.bak,*.pyc,*.class
set wildoptions=pum
set pumblend=20
set title
set mouse=a
set inccommand=split
" folds
set foldmethod=indent
set foldnestmax=10
set nofoldenable
set foldlevel=2
" turn backup off partially
set nobackup
set noswapfile
set nowb
set nospell

" completion settings
set completeopt=menuone,noinsert,noselect
set shortmess+=c

set cmdheight=2
set signcolumn=yes

" for gitgutter
set updatetime=300

" tab settings
set tabstop=4
set shiftwidth=4
set expandtab

" line numbers
"set number
"set relativenumber

set autowrite
set hidden
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
" automatically read edited files from disk instead of asking
set autoread


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

" git
autocmd FileType gitcommit,gitrebase,gitconfig set bufhidden=delete

" gopass
au BufNewFile,BufRead /dev/shm/gopass.* setlocal noswapfile nobackup
