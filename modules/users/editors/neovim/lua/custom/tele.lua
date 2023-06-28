local M = {}

function M.live_grep()
	local theme = {
		path_display = { "shorten", "absolute" },
		fzf_separator = "|>",
	}
	require("telescope.builtin").live_grep(theme)
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
			"shorten",
			"absolute",
		},
	}
	require("telescope.builtin").buffers(theme)
end

function M.find_dotfiles()
	require("telescope.builtin").git_files({
		path_display = { "shorten" },
		cwd = "~/Documents/gits/dotfiles-nix/",
	})
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
