-- HELP: see :h luasnip
local ls = require'luasnip'

-- some shorthands...
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local types = require("luasnip.util.types")

-- Every unspecified option will be set to the default.
ls.config.set_config({
	history = true,
	-- Update more often, :h events for more info.
	updateevents = "TextChanged,TextChangedI",
	ext_opts = {
		[types.choiceNode] = {
			active = {
				virt_text = { { "choiceNode", "Comment" } },
			},
		},
	},
	-- treesitter-hl has 100, use something higher (default is 200).
	ext_base_prio = 300,
	-- minimal increase in priority.
	ext_prio_increase = 1,
	enable_autosnippets = true,
})

ls.snippets = {
    python = {
        s("main", {
            t({"def main():", "\t"}), i(0),
            t({"", "", "", "if __name__ == '__main__':", "\tmain()"}),
        }),
    },
    fortran = {
        s("subroutine", {
            t("subroutine "), i(1, "foo"),
            t({"", "\t"}), i(0, "! code ~"),
            t({"", "end subroutine "}), f(function(args) return args[1][1] end, {1})
        }),
        s("function", {
            t("function "), i(1, "foo"),
            t({"", "\t"}), i(0, "! code ~"),
            t({"", "end function "}), f(function(args) return args[1][1] end, {1})
        }),
        s("pr", { t("print*, "), i(0) }),
    },
}
