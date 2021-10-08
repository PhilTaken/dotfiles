local should_reload = true

local reloader = function()
    if should_reload then
        RELOAD('plenary')
        RELOAD('popup')
        RELOAD('telescope')
    end
end

reloader()


local M = {}

function M.live_grep()
    local theme = {
        path_display = { 'shorten', 'absolute' },
        fzf_separator = "|>",
    }
    require('telescope.builtin').live_grep(theme)
end

function M.project_search()
    local theme = require('telescope.themes').get_dropdown()
    theme['path_display'] = { 'shorten', 'absolute' }
    require('telescope.builtin').git_files(theme)
end

function M.buffers()
    local theme = {
        show_all_buffers = true,
        path_display = {
            "shorten",
            "absolute",
        },
    }
    require('telescope.builtin').buffers(theme)
end

function M.find_dotfiles()
    require('telescope.builtin').git_files{
        path_display = { "shorten" },
        cwd = '~/Documents/gits/dotfiles-nix/',
    }
end

return setmetatable({}, {
    __index = function(_, k)
        reloader()

        if M[k] then
            return M[k]
        else
            return require('telescope.builtin')[k]
        end
    end
})
