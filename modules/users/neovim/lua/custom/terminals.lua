local Terminal  = require('toggleterm.terminal').Terminal

local M = {}

M.sideterminal = Terminal:new({
    direction = 'vertical',
    on_open = function(term)
        vim.cmd("startinsert!")
        vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
    end,
    close_on_exit = true,
})

M.bgshell = Terminal:new({
    direction = "float",
    float_opts = {
        border = "double",
    },
    close_on_exit = true,
})

M.lazygit = Terminal:new({
    cmd = "lazygit",
    direction = "float",
    hidden = true,
    float_opts = {
        border = "double",
    },
    close_on_exit = true,
})

M.bottom = Terminal:new({
    cmd = "btm",
    direction = "float",
    float_opts = {
        border = "double",
    },
    close_on_exit = true,
})

return M
