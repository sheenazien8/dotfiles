local lspconfig = require("lspconfig")
local c = require('sheena.lspconfig.lang.custom')

-- symbols for autocomplete
-- lspconfig.sumneko_lua.setup(c.default(require('sheena.lspconfig.lang.lua')))
lspconfig.sumneko_lua.setup(c.default(require('sheena.lspconfig.lang.lua'), "sumneko_lua"))
-- lspconfig.gopls.setup(c.default(require('sheena.lspconfig.lang.golang')))
lspconfig.intelephense.setup(c.default(require('sheena.lspconfig.lang.intelephense'), "intelephense"))
lspconfig.sqls.setup(c.default(require('sheena.lspconfig.lang.sqls'), "sqls"))
lspconfig.html.setup(c.default(require('sheena.lspconfig.lang.html'), "html"))
--[[ lspconfig.emmet_ls.setup(c.default(require('sheena.lspconfig.lang.emmet_ls'), "emmet_ls")) ]]

local servers = {'bashls', 'tsserver', 'vuels', 'tailwindcss', 'gopls', 'cssls', 'cssmodules_ls', 'dartls', 'graphql', 'vimls'}
for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup(c.default(nil, lsp))
end
