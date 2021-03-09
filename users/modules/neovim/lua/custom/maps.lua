local cmd = vim.cmd
local map = vim.api.nvim_set_keymap
local options = { noremap = true; silent = true; }

-- autocommands
--cmd('au BufNewFile,BufRead * if &ft == "" | set ft=text | endif')
cmd[[au BufNewFile,BufRead /dev/shm/gopass.* setlocal noswapfile nobackup]]
cmd[[au TextYankPost * silent! lua vim.highlight.on_yank { higroup="IncSearch", timeout=1000, on_visual=false }]]
cmd[[au CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics()]]

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
map('n', '<Tab>', ':bn<CR>', {})
map('n', '<S-Tab>', ':bp<CR>', {})

-- remap number in/decrement
map('n', '<A-a>', 'C-a', options)
map('n', '<A-x>', 'C-x', options)

-- disable highlight
map('n', '<leader><leader>', ':noh<CR>', options)

-- search using visual mode
map('v', '/', 'y/<C-R>"<CR>', options)

-- escape in/out of terminal mode
map('t', 'jj', '<C-\\><C-n>', { noremap = true; })

-- telescope mappings
map('n', "<leader>t", ":lua require('telescope.builtin').treesitter()<cr>", options)
map('n', "<leader>g", ":lua require('telescope.builtin').live_grep()<cr>", options)
map('n', "<leader>f", ":lua require('telescope.builtin').find_files()<cr>", options)
map('n', ";", ":lua require('telescope.builtin').buffers{ show_all_buffers = true }<cr>", options)
map('n', ";;", ":lua require('telescope.builtin').git_files()<cr>", options)

-- snippets
cmd[[inoremap <c-e> <cmd>lua return require'snippets'.expand_or_advance(1)<CR>]]
cmd[[inoremap <c-n> <cmd>lua return require'snippets'.expand_or_advance(-1)<CR>]]

-- lsp commands
map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', { noremap = true; silent = true; })
map('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<CR>', { noremap = true; silent = true; })
map('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', { noremap = true; silent = true; })
map('n', '<leader>=', '<cmd>lua vim.lsp.buf.formatting()<CR>', { noremap = true; silent = true; })

----------------------------------------------

-- tab completion
map("i", "<Tab>",   "v:lua.tab_complete()",   {expr = true})
map("s", "<Tab>",   "v:lua.tab_complete()",   {expr = true})
map("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
map("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})

-- compe
map('i', '<C-Space>', [[compe#complete()]],                             {noremap = true; expr = true; silent = true;})
map('i', '<CR>',      [[compe#confirm('<CR>')]],                              {noremap = true; expr = true; silent = true;})
map('i', '<C-e>',     [[compe#close('<C-e>')]],                         {noremap = true; expr = true; silent = true;})
map('i', '<C-f>',     [[compe#scroll({ 'delta': +4 })]],                {noremap = true; expr = true; silent = true;})
map('i', '<C-d>',     [[compe#scroll({ 'delta': -4 })]],                {noremap = true; expr = true; silent = true;})
