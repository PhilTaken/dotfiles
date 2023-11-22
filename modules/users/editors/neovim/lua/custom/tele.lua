local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values

local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local M = {}

function M.git_workspace(opts)
  opts = opts or require("telescope.themes").get_dropdown{}
  local path = vim.env.GIT_WORKSPACE
  local repos = vim.split(io.popen("git workspace list"):read("*a"), "\n")

  pickers.new(opts, {
    prompt_title = "Projects",
    finder = finders.new_table {
      results = repos
    },
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        vim.api.nvim_set_current_dir(path .. "/" .. selection[1])

        M.find_files()
    end)
      return true
    end,
  }):find()
end


function M.find_files()
	local theme = {
		path_display = { "truncate" },
		fzf_separator = "|>",
	}
	require("telescope.builtin").find_files(theme)
end

function M.live_grep()
	local theme = {
		path_display = { "truncate" },
		fzf_separator = "|>",
	}
	require("telescope").extensions.egrepify.egrepify(theme)
	--require("telescope.builtin").live_grep(theme)
end

function M.project_search()
	local theme = require("telescope.themes").get_dropdown()
	theme["path_display"] = { "shorten", "absolute" }
	require("telescope.builtin").git_files(theme)
end

function M.buffers()
	local theme = {
		show_all_buffers = true,
		path_display = {
			"truncate",
		},
	}
	require("telescope.builtin").buffers(theme)
end

return setmetatable({}, {
	__index = function(_, k)
		if M[k] then
			return M[k]
		elseif require("telescope.builtin")[k] then
			return require("telescope.builtin")[k]
		else
			return require("telescope")[k]
		end
	end,
})
