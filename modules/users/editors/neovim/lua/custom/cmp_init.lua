-- nvim-cmp
local cmp = require 'cmp'
local lspkind = require 'lspkind'

cmp.setup {
    completion = {
        completeopt = 'menu,menuone,noinsert',
    },
    mapping = cmp.mapping.preset.insert({
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-e>"] = cmp.mapping.close(),
        ["<c-y>"] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Insert,
            select = true,
        },
        ["<c-space>"] = cmp.mapping.complete(),
    }),

    sources = {
        { name = "luasnip" },
        { name = "nvim_lua" },
        { name = "nvim_lsp" },
        { name = "path" },
        { name = "buffer", keyword_length = 5 },
        { name = "tmux" },
        { name = "latex_symbols" },
        --{ name = "zsh" },    -> tamago324/cmp-zsh
    },

    sorting = {
        comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            require "cmp-under-comparator".under,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
        },
    },

    snippet = {
        expand = function(args)
            require("luasnip").lsp_expand(args.body)
        end,
    },

    formatting = {
        format = lspkind.cmp_format {
            with_text = true,
            menu = {
                nvim_lua = "[api]",
                buffer = "[buf]",
                nvim_lsp = "[LSP]",
                path = "[path]",
                tmux = "[tmux]",
                latex_symbols = "[latex]",
                luasnip = "[snip]",
            },
        },
    },

    experimental = {
        native_menu = false,
        ghost_text = true,
    },
}

cmp.setup.cmdline {
  mapping = cmp.mapping.preset.cmdline({
    -- Your configuration here.
  })
}
