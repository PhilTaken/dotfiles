local cmd = vim.cmd
local map = vim.api.nvim_set_keymap
local options = { noremap = true; }

cmd('au BufNewFile,BufRead * if &ft == "" | set ft=text | endif')
cmd('au BufNewFile,BufRead /dev/shm/gopass.* setlocal noswapfile nobackup')
cmd("autocmd VimResized * redraw!")
cmd('au TextYankPost * silent! lua vim.highlight.on_yank { higroup="IncSearch", timeout=1000, on_visual=false }')
cmd('autocmd FileType vimwiki set syntax=markdown.pandoc')

map('n', '<Tab>', ':bn<CR>', options)
map('n', '<S-Tab', ':bp<CR>', options)

map('n', '<A-a>', 'C-a', options)
map('n', '<A-x>', 'C-x', options)

map('n', '<leader><leader>', ':noh<CR>', options)

map('v', '/', 'y/<C-R>"<CR>', options)


map('n', "<c-f>", ":lua require('telescope.builtin').treesitter()<cr>",options)
map('n', "<c-u>", ":lua require('telescope.builtin').live_grep()<cr>",options)
map('n', "<c-p>", ":lua require('telescope.builtin').find_files()<cr>",options)
map('n', ";", ":lua require('telescope.builtin').buffers{ show_all_buffers = true }<cr>",options)
map('n', ";;", ":lua require('telescope.builtin').git_files()<cr>",options)


function _G.create_augroup(autocmds, name)
    cmd('augroup ' .. name)
    cmd('autocmd!')
    for _, autocmd in ipairs(autocmds) do
        cmd('autocmd ' .. table.concat(autocmd, ' '))
    end
    cmd('augroup END')
end

create_augroup({
    'FileType vimwiki nmap <buffer><silent> <CR> <Plug>VimwikiFollowLink',
    'FileType vimwiki nmap <buffer><silent> <Backspace> <Plug>VimwikiGoBackLink',
    'FileType vimwiki nmap <buffer><silent> <leader>ww <Plug>VimwikiIndex',
}, "vimwiki_mappings")


-- Highlight on yank
create_augroup({
    [[ autocmd TextYankPost * silent! lua vim.highlight.on_yank() ]],
}, "YankHighlight")

map('n', '<F6>', [[:let _s=@/ <Bar> :%s/\s\+$//e <Bar> :let @/=_s <Bar> :nohl <Bar> :unlet _s <CR>]], { noremap = true, silent = true})

----------------------------------------------

local check_back_space = function()
    local col = vim.fn.col('.') - 1
    if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
        return true
    else
        return false
    end
end

local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-n>"
  -- elseif vim.fn.call("vsnip#available", {1}) == 1 then
  --   return t "<Plug>(vsnip-expand-or-jump)"
  elseif check_back_space() then
    return t "<Tab>"
  else
    return vim.fn['compe#complete']()
  end
end
_G.s_tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-p>"
  -- elseif vim.fn.call("vsnip#jumpable", {-1}) == 1 then
  -- me-
  --   return t "<Plug>(vsnip-jump-prev)"
  else
    return t "<S-Tab>"
  end
end

vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
