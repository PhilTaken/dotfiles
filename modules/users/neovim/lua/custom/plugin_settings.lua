-- telescope
require('custom.tele_init')

-- snippets
--require('custom.snippets')

-- setup treesitter
require'nvim-treesitter.configs'.setup {
    ensure_installed = "maintained",
    highlight = {
        enable = true,
    },
}

local iron = require('iron')

iron.core.add_repl_definitions {
    python = {
        ipython = {
            command = { "ipython", "--no-autoindent" }
        }
    }
}

iron.core.set_config {
    preferred = {
        python = "ipython",
    }
}

-- nvim-cmp
local cmp = require 'cmp'
local lspkind = require 'lspkind'

cmp.setup {
  mapping = {
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-e>"] = cmp.mapping.close(),
    ["<c-y>"] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    },
    ["<c-space>"] = cmp.mapping.complete(),
  },

  sources = {
    { name = "nvim_lua" },
    { name = "nvim_lsp" },
    { name = "path" },
    { name = "buffer", keyword_length = 5 },
    { name = "tmux" },
    { name = "latex_symbols" },
    { name = "luasnip" },
    --{ name = "zsh" },    -> tamago324/cmp-zsh
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
        --luasnip = "[snip]",
      },
    },
  },

  experimental = {
    native_menu = false,
    ghost_text = true,
  },
}
