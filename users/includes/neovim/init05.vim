" My vimrc ~
"
"                   WNNW                         WWW                   
"                 WNKkOXW                        Kk0NW                 
"               WNKkxxkOKN                       Kxdk0NW               
"             WNKkxxxxkkk0NW                     Kxdodx0N              
"            NKkxddddxkkkkOXW                    Kdoooodx0N            
"         WN0kxdddddddxkkkkOKN                   Kdoooooodx0N          
"       WN0xodddddddddxkkkkkk0NW                 Kdooooooooox0N        
"      WKxdoolodddddddxkkkkkkkOXW                KdoooooooooooxKW      
"      NkoooooloddddddxkkkkkkkkkKN               KdooooooooooookX      
"      Nkoooooolooddddxkkkkkkkkkk0NW             KdooooooooooooxX      
"      NkooooooollodddxxkxxxkkkkkkOXWW           KdllllllllllloxX      
"      NkoooooooolloodxxxxxxxxxxxxxkOKW          KdllllllllllllxX      
"      Nkooooooooolllodxxxxxxxxxxxxxxk0N         KdllllllllllllxX      
"      NkoooooooooollldxxxxxxxxxxxxxxxxOXW       KollllllllllllxX      
"      NklllllllllloloO0kxxxxxxxxxxxxxxxkKW      KollllllllllllxX      
"      Nkllllllllllllo0WXOxxxxxxxxxxxxxxxx0N     KollllllllllllxX      
"      Nkllllllllllllo0  NOxxxxxxxxxxxxxxxxOXW   KoclcccllccllldX      
"      Nxllllllllllllo0   N0xxxxxxxxxxxxxxxxkKW  KoccccccccccccdX      
"      Nxllllllllllllo0    WKkxdxxxxxxxxxxxxxx0NWKoccccccccccccdX      
"      Nxllllllllllllo0     WXOxddddddddddddxdxOX0occccccccccccdX      
"      Nxllllllllllllo0       N0xdddddddddddddddkxlccccccccccccdX      
"      Nxllccccllcclco0        WKkdddddddddddddddolccccccccccccdX      
"      Nxcccccccccccco0         WXkddddddddddddddolccccccccccccdX      
"      Nxcccccccccccco0           NOxxdddddddddddollccc::::::::oX      
"      Nxccccccccccccl0            WX0xddddddddddolllcc::::::::oX      
"      Nxccccccccccccl0              WXkdddddddddolccccc:::::::oK      
"      Nkccccccccccccl0                NOddddddddolccccccc:::::dX      
"       NOoccccccccccl0                 N0xooooooolcccccccc::lkXW      
"        WNOoccc:cc::l0                  WKxoooooocccccccccokXW        
"          WNOoc:::::l0                   WXkdooolcccccccokXW          
"            WNOoc:::l0                     N0doolcccccokXW            
"               NOo::l0                      WKxolcccokXW              
"                WXOolO                       WXklclkXW                
"                  WX0X                         NOOXW                  

" disable legacy vim options
"set nocompatible

" ideas
" -----
" undodir
" undofile
" colorcolumn (80)
"
" floaterm

" -----------------------
"          Plugins
" -----------------------
" repl support
"Plug 'hkupty/iron.nvim'
"Plug 'kristijanhusak/completion-tags'
"Plug 'albertoCaroM/completion-tmux'

"filetype plugin indent on

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

" set up colorizer
"lua  <<EOF
"require'colorizer'.setup { 
"    '*';
"    css = { rgb_fn = true; };
"}
"EOF

" ---------------------------
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
set number
set relativenumber

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
" vim rooter
let g:rooter_tarets = '/,*'
let g:rooter_patterns = ['Rakefile', '.git/']
let g:rooter_resolve_links = 1

" pandoc
let g:pandoc#spell#enabled = 0

" vimtex
let g:vimtex_compiler_progname = 'nvr'
let g:vimtex_view_general_viewer = 'zathura'
let g:tex_flavor = 'latex'

let g:echodoc#type = 'signature'
let g:echodoc#enable_at_startup = 1

" nerd commenter
let g:NERDDefaultAlign = 'left'
let g:NERDToggleCheckAllLines = 1

" ultisnips
let g:UltiSnipsExpandTrigger = "JJ"
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-k>"
let g:UltiSnipsEditSplit="horizontal"
let g:UltiSnipsSnippetDirectories=[$HOME.'/.config/nvim/ultisnips']

" airline
let g:airline_powerline_fonts = 1
let g:airline#extensions#whitespace#enabled = 0

" auto redraw
autocmd VimResized * redraw!

" pear tree smart placement of brackets etc
let g:pear_tree_smart_openers = 1
let g:pear_tree_smart_closers = 1
let g:pear_tree_smart_backspace = 1

" tmux
let g:tmux_navigator_no_mappings = 1
" Update changed buffer when switching to Tmux
let g:tmux_navigator_save_on_switch = 1
let g:tmuxline_preset = 'vim_powerline_1'
let g:tmuxline_preset = {
      \'a'    : '#S',
      \'win'  : ['#I', '#W'],
      \'cwin' : ['#I', '#W'],
      \'x'    : '#(whoami)@#H',
      \'z'    : '%a %R'}

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

" fzf / skim
"noremap <Leader>f :Rg<CR>
"nnoremap ;; :Files<CR>
"noremap ; :Buffers<CR>

" git alias commands
command! Gl :Git pull
command! Gs :Gstatus
command! Ga :Git add %
command! Gc :Gcommit
command! Gr :Git reset
command! Gp :Git push

" ---------------------------
"         autocommands
" ---------------------------
" Delete trailing whitespace on save, useful for Python, Rust and cpp ;)
func! DeleteTrailingWS()
  exe "normal mz"
  %s/\s\+$//ge
  exe "normal `z"
endfunc

augroup buf_write
    autocmd!
    autocmd BufWrite *.go :call DeleteTrailingWS()
    autocmd BufWrite *.py :call DeleteTrailingWS()
    autocmd BufWrite *.cpp :call DeleteTrailingWS()
    autocmd BufWrite *.c :call DeleteTrailingWS()
    autocmd BufWrite *.h :call DeleteTrailingWS()
    autocmd BufWrite *.rs :call DeleteTrailingWS()
augroup END

" nvr as git tool in terminal
if has('nvim')
  let $GIT_EDITOR = 'nvr -cc split --remote-wait'
endif

" git
autocmd FileType gitcommit,gitrebase,gitconfig set bufhidden=delete

" gopass
au BufNewFile,BufRead /dev/shm/gopass.* setlocal noswapfile nobackup noundofile

" lua lsp stuff (copied)
syntax enable
lua <<EOF

-- setup treesitter
-- require "nvim-treesitter.parsers".get_parser_configs().markdown = nil

require'nvim-treesitter.configs'.setup {
    ensure_installed = {
        "rust", "c", "python", "lua",
        "nix", "json", "html", "cpp",
        "toml", "bash", "markdown",
        "rst", "css", "javascript",
        "regex", "yaml", "php"
    },
    highlight = {
        enable = true,              -- false will disable the whole extension
    },
}

-- setup dev icons
require'nvim-web-devicons'.setup()

local telescope = require'telescope.builtin'

-- nvim_lsp object
local lsp = require'lspconfig'

-- Enable rust_analyzer, pyls and texlab
lsp.rust_analyzer.setup{}
lsp.texlab.setup{}
lsp.clangd.setup{}
lsp.pyls.setup{}
EOF

autocmd BufEnter * lua require'completion'.on_attach()

" Show diagnostic popup on cursor hold
autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics()


inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Enable type inlay hints
" TODO improve this to right aligned
" autocmd CursorHold,CursorHoldI * lua require'lsp_extensions'.inlay_hints{prefix = '> ', highlight = "Comment", aligned=true}

" telescope mappings
nnoremap <c-f> :lua require'telescope.builtin'.treesitter{}<CR>
nnoremap <c-u> :lua require'telescope.builtin'.live_grep{}<CR>
nnoremap <c-p> :lua require'telescope.builtin'.find_files{}<CR>
nnoremap ;     :lua require'telescope.builtin'.buffers{ show_all_buffers = true }<CR>
nnoremap ;;    :lua require'telescope.builtin'.git_files{}<CR>

let g:completion_enable_snippet = 'UltiSnips'
let g:completion_chain_complete_list = {
    \ 'default': [
    \    { 'complete_items': [ 'lsp', 'snippet', 'ts', 'buffers', 'tags', 'tmux']},
    \ ]}



" deactivate default mappings
let g:iron_map_defaults=0
" define custom mappings for the python filetype
"
"augroup ironmapping
"    autocmd!
"    autocmd Filetype python nmap <buffer> <leader>t <Plug>(iron-send-motion)
"    autocmd Filetype python vmap <buffer> <leader>t <Plug>(iron-send-motion)
"    autocmd Filetype python nmap <buffer> <leader>p <Plug>(iron-repeat-cmd)
"augroup END
