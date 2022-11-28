require('sheena.core.mappings')
require('sheena.plugins')
require('sheena.plugins.default')
require('sheena.plugins.indentline')
require('sheena.plugins.nvimtree')
require('sheena.plugins.vimwiki')
-- print(vim.inspect(require('sheena.plugins.gotoworkspace.init')))
require('sheena.plugins.telescope')
require('sheena.plugins.cmp')
require('sheena.plugins.luasnip')
require('sheena.lspconfig')()
require('sheena.plugins.treesitter')
require('sheena.plugins.lualine')
-- require('sheena.plugins.refactor')
require('sheena.plugins.terminal')
require('sheena.plugins.flutter')
require('sheena.plugins.hop')
require('sheena.plugins.dap')
require('sheena.plugins.gitsigns')
require('sheena.plugins.whichkey')
require('sheena.plugins.winbar')
require('sheena.core.settings')
require('sheena.theme.init').setup({
  theme = "gruvbox"
})


-- local opts = { noremap = true, silent = true }
--
-- vim.keymap.set("n", "<Leader><Leader>i", "<cmd>PickIcons<cr>", opts)
-- vim.keymap.set("i", "<C-i>", "<cmd>PickInsert<cr>", opts)
-- vim.keymap.set("i", "<A-i>", "<cmd>PickAltFontAndSymbolsInsert<cr>", opts)
