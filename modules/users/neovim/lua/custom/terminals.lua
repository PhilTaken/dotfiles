local Terminal  = require('toggleterm.terminal').Terminal

local lazygit = Terminal:new({
    cmd = "lazygit",
    direction = "float",
    float_opts = {
        border = "double",
    },
})

local bottom = Terminal:new({
    cmd = "btm",
    direction = "float",
    float_opts = {
        border = "double",
    },
})

local bgshell = Terminal:new({
    direction = "float",
    float_opts = {
        border = "double",
    }
})

return {
    lazygit = lazygit,
    bottom = bottom,
    bgshell = bgshell
}
