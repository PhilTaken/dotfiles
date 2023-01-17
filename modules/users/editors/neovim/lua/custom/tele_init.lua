local actions = require('telescope.actions')
local sorters = require('telescope.sorters')

require('telescope').setup {
    pickers = {
      find_files = {
        find_command = {"rg", "--files", "--hidden", "--ignore", "-u", "--glob=!**/.git/*", "--glob=!**/node_modules/*", "--glob=!**/.next/*"},
      }
    },
    defaults = {
        prompt_prefix = '❯ ',
        selection_caret = '❯ ',

        winblend = 0,

        layout_strategy = 'horizontal',
        layout_config = {
            prompt_position = "top",
            preview_cutoff = 120,
            horizontal = {
                width_padding = 0.1,
                height_padding = 0.1,
                preview_width = 0.6,
            },
            vertical = {
                width_padding = 0.05,
                height_padding = 1,
                preview_height = 0.5,
            }
        },

        selection_strategy = "reset",
        sorting_strategy = "descending",
        scroll_strategy = "cycle",
        color_devicons = true,


        mappings = {
            i = {
                ['<esc>'] = actions.close,
            },
        },

        borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰'},

        --file_sorter = sorters.get_fzy_sorter,

        --file_previewer   = require('telescope.previewers').vim_buffer_cat.new,
        --grep_previewer   = require('telescope.previewers').vim_buffer_vimgrep.new,
        --qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,
    },
}
