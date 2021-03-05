local cmd = vim.cmd
local map = vim.api.nvim_set_keymap
local options = { noremap = true; silent = true; }

-- autocommands
--cmd('au BufNewFile,BufRead * if &ft == "" | set ft=text | endif')
cmd[[au BufNewFile,BufRead /dev/shm/gopass.* setlocal noswapfile nobackup]]
cmd[[au TextYankPost * silent! lua vim.highlight.on_yank { higroup="IncSearch", timeout=1000, on_visual=false }]]
--cmd[[au BufRead,BufNewFile *.nix set filetype=nix]]

-- vimwiki mappings
cmd[[au FileType vimwiki nmap <buffer><silent> <CR> <Plug>VimwikiFollowLink']]
cmd[[au FileType vimwiki nmap <buffer><silent> <Backspace> <Plug>VimwikiGoBackLink']]
cmd[[au FileType vimwiki nmap <buffer><silent> <leader>ww <Plug>VimwikiIndex']]
cmd[[au FileType vimwiki set syntax=markdown.pandoc]]

-- floaterm execution
--cmd[[au FileType rust nmap <buffer><silent> <leader>a :FloatermNew ]]

-- strip trailing whitespaces
cmd[[au FileType c,cpp,python,rust,nix,lua,ruby autocmd BufWritePre <buffer> :%s/\s\+$//e]]

cmd[[au VimResized * redraw!]]
cmd[[au TextYankPost * silent! lua vim.highlight.on_yank()]]

-- for easy buffer navigation
map('n', '<Tab>', ':bn<CR>', options)
map('n', '<S-Tab', ':bp<CR>', options)

-- remap number in/decrement
map('n', '<A-a>', 'C-a', options)
map('n', '<A-x>', 'C-x', options)

-- disable highlight
map('n', '<leader><leader>', ':noh<CR>', options)

map('v', '/', 'y/<C-R>"<CR>', options)

map('n', "<c-f>", ":lua require('telescope.builtin').treesitter()<cr>", options)
map('n', "<c-u>", ":lua require('telescope.builtin').live_grep()<cr>", options)
map('n', "<c-p>", ":lua require('telescope.builtin').find_files()<cr>", options)
map('n', ";", ":lua require('telescope.builtin').buffers{ show_all_buffers = true }<cr>", options)
map('n', ";;", ":lua require('telescope.builtin').git_files()<cr>", options)

-- remove whitespaces
map('n', '<F6>', [[:let _s=@/ <Bar> :%s/\s\+$//e <Bar> :let @/=_s <Bar> :nohl <Bar> :unlet _s <CR>]], options)

----------------------------------------------

-- tab completion
map("i", "<Tab>",   "v:lua.tab_complete()",   {expr = true})
map("s", "<Tab>",   "v:lua.tab_complete()",   {expr = true})
map("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
map("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})

-- compe
map('i', '<C-Space>', [[compe#complete()]],                             {noremap = true; expr = true; silent = true;})
map('i', '<CR>',      [[compe#confirm(lexima#expand('<LT>CR>', 'i'))]], {noremap = true; expr = true; silent = true;})
map('i', '<C-e>',     [[compe#close('<C-e>')]],                         {noremap = true; expr = true; silent = true;})
map('i', '<C-f>',     [[compe#scroll({ 'delta': +4 })]],                {noremap = true; expr = true; silent = true;})
map('i', '<C-d>',     [[compe#scroll({ 'delta': -4 })]],                {noremap = true; expr = true; silent = true;})

-- snippets
cmd[[inoremap <c-e> <cmd>lua return require'snippets'.expand_or_advance(1)<CR>]]
cmd[[inoremap <c-n> <cmd>lua return require'snippets'.expand_or_advance(-1)<CR>]]
