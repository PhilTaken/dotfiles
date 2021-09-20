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

" leader
let mapleader="\<Space>"

" add my lua plugins to runtimepath
" TODO make this a plugin
lua << EOF
local uv = vim.loop
local plugindir = "/home/nixos/Documents/personal/nvim_plugins/"

local dir = uv.fs_opendir(plugindir, nil, 200)
local entries = uv.fs_readdir(dir, nil)
uv.fs_closedir(dir)

local dirs = vim.tbl_filter(function(entry)
    return entry.type == "directory"
end, entries)

vim.tbl_map(function(entry)
    vim.api.nvim_exec("set runtimepath+=" .. plugindir .. entry.name, false)
end, dirs)
EOF

" colorscheme
set termguicolors
let ayucolor="mirage"
try
    colorscheme ayu
catch /^Vim\%((\a\+)\)\=:E185/
    colorscheme koehler
endtry

if !isdirectory($XDG_DATA_HOME."/nvim/undodir")
    call mkdir($XDG_DATA_HOME."/nvim/undodir", "", 0770)
endif

set undodir=$XDG_DATA_HOME/nvim/undodir
set undofile


"---------------------------
"           sets
" ---------------------------

set wildignore=*.swp,*.bak,*.pyc,*.class
set pumblend=20
set mouse=a
set inccommand=split
" folds
set foldmethod=indent
set foldnestmax=10
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
set copyindent
set backspace=indent,eol,start
set shiftround
set pastetoggle=<F3>
set timeoutlen=300
set ttimeoutlen=0
" automatically read edited files from disk instead of asking
"set nolangremap


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
"let g:vimtex_compiler_progname = 'nvr'
let g:vimtex_view_general_viewer = 'zathura'
let g:tex_flavor = 'latex'

"let g:echodoc#type = 'signature'
"let g:echodoc#enable_at_startup = 1

" nerd commenter
let g:NERDDefaultAlign = 'left'
let g:NERDToggleCheckAllLines = 1

" ultisnips
let g:UltiSnipsExpandTrigger = "JJ"
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-k>"
let g:UltiSnipsEditSplit="horizontal"
let g:UltiSnipsSnippetDirectories=[$HOME.'/.config/nvim/ultisnips']

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

" ---------------------------
"         autocommands
" ---------------------------
" Delete trailing whitespace on save, useful for Python, Rust and cpp ;)
func! DeleteTrailingWS()
  exe "normal mz"
  %s/\s\+$//e
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
    autocmd BufWrite *.lua :call DeleteTrailingWS()
augroup END

" git
autocmd FileType gitcommit,gitrebase,gitconfig set bufhidden=delete

" gopass
au BufNewFile,BufRead /dev/shm/gopass.* setlocal noswapfile nobackup

" lua lsp stuff
syntax enable
lua <<EOF
-- setup treesitter
require'nvim-treesitter.configs'.setup {
    ensure_installed = {
        "json", "html", "toml",
        "bash", "css", "yaml"
    },
    highlight = {
        enable = true,
    },
}

-- setup dev icons
require'nvim-web-devicons'.setup()

-- set escape in insert mode to leave
local actions = require('telescope.actions')
require('telescope').setup{
    defaults = {
        mappings = {
            i = {
                ["<esc>"] = actions.close
            },
        },
    }
}

-- nvim_lsp object
local lsp = require'lspconfig'

-- Enable lsp servers
lsp.rust_analyzer.setup{}
lsp.texlab.setup{}
lsp.ccls.setup{}
lsp.pyright.setup{}
lsp.rnix.setup{}
lsp.fortls.setup { 
    cmd = { "fortls", "--lowercase_intrinsics", "--hover_signature", "--enable_code_actions", "--debug_log" }
    root_dir = lsp.util.root_pattern('.git');
}
lsp.sumneko_lua.setup {
    cmd = { "lua-language-server" };
    settings = {
        Lua = {
            runtime = {
                version = 'LuaJIT',
                path = vim.split(package.path, ';'),
            },
            diagnostics = {
                globals = {'vim'},
            },
            workspace = {
                library = {
                    [vim.fn.expand('$VIMRUNTIME/lua')] = true,
                    [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
                },
            },
        },
    };
}

require'custom.statusline'
EOF

autocmd BufEnter * lua require'completion'.on_attach()
autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics()
au TextYankPost * silent! lua vim.highlight.on_yank { higroup="IncSearch", timeout=1000, on_visual=false }

inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" telescope mappings
nnoremap <c-f> <cmd>lua require('telescope.builtin').treesitter()<cr>
nnoremap <c-u> <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <c-p> <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap ;     <cmd>lua require('telescope.builtin').buffers{ show_all_buffers = true }<cr>
nnoremap ;;    <cmd>lua require('telescope.builtin').git_files()<cr>

let g:completion_enable_snippet = 'UltiSnips'
let g:completion_chain_complete_list = [
    \{ 'complete_items': [ 'lsp', 'snippet', 'path' ]},
    \{ 'complete_items': [ 'ts', 'buffers' ]}
\]
let g:completion_auto_change_source = 1

" define custom mappings for the python filetype
"
"augroup ironmapping
"    autocmd!
"    autocmd Filetype python nmap <buffer> <leader>t <Plug>(iron-send-motion)
"    autocmd Filetype python vmap <buffer> <leader>t <Plug>(iron-send-motion)
"    autocmd Filetype python nmap <buffer> <leader>p <Plug>(iron-repeat-cmd)
"augroup END

augroup pandoc_syntax
    autocmd! FileType vimwiki set syntax=markdown.pandoc
augroup END

" vimwiki mappings - custom
let g:vimwiki_key_mappings = { 
            \ 'global': 0,
            \ 'links': 0,
            \ 'html': 0,
            \ 'mouse': 0,
            \ 'table_mappings': 0,
            \ }

augroup vimwiki_mappings
    autocmd! vimwiki_mappings
    autocmd Filetype vimwiki nmap <buffer><silent> <CR> <Plug>VimwikiFollowLink
    autocmd Filetype vimwiki nmap <buffer><silent> <Backspace> <Plug>VimwikiGoBackLink
    autocmd Filetype vimwiki nmap <buffer><silent> <Leader>ww <Plug>VimwikiIndex
augroup END
