local cmd = vim.cmd
local map = vim.api.nvim_set_keymap
local options = { noremap = true; }


cmd('au BufNewFile,BufRead * if &ft == "" | set ft=text | endif')
cmd('au BufNewFile,BufRead /dev/shm/gopass.* setlocal noswapfile nobackup')
cmd("autocmd VimResized * redraw!")
cmd('au TextYankPost * silent! lua vim.highlight.on_yank { higroup="IncSearch", timeout=1000, on_visual=false }')

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
