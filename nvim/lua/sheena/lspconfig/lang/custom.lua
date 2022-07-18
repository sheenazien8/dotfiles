--[[ vim.notify = require("notify") ]]
ServerName = ""
local M = {}
function M.custom_on_init()
  --[[ vim.notify("Language Server Protocol started!", "info", {
    title = "LSP Info",
  }) ]]

  print("Language Server Protocol started!")
end
function M.custom_capabilities()
  local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  return capabilities
end
function M.custom_cwd()
  if vim.loop.cwd() == vim.loop.os_homedir() then
    return vim.fn.expand("%:p:h")
  end
  return vim.loop.cwd()
end

function M.on_attach(client, bufnr)
  require('sqls').on_attach(client, bufnr)
  -- require('folding').on_attach()
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc<cr>')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- use builtinlsp
  buf_set_keymap('n', '<space>fd', ':lua vim.lsp.buf.formatting()<CR>', opts)
  buf_set_keymap("n", "gd", ":lua vim.lsp.buf.definition()<CR>", {silent = true})
  buf_set_keymap("n", "gD", ":lua vim.lsp.buf.declaration()<CR>", {silent = true})

  buf_set_keymap("n", "K", ":lua vim.lsp.buf.hover()<CR>", {silent = true})
  buf_set_keymap("n", "<leader>ca", ":lua vim.lsp.buf.code_action()<CR>", {silent = true})
  buf_set_keymap('n', '<space>d', ':lua vim.diagnostic.setqflist()<CR>', {silent = true})
  buf_set_keymap('n', '<space>e', ':lua vim.diagnostic.open_float()<CR>', {silent = true})
  buf_set_keymap("n", "gr", ":lua vim.lsp.buf.references()<CR>", {silent = true})
  buf_set_keymap("n", "gi", ":lua vim.lsp.buf.implementation()<CR>", {silent = true})
  buf_set_keymap('n', '[g', ':lua vim.diagnostic.goto_prev()<CR>', {silent = true})
  buf_set_keymap('n', ']g', ':lua vim.diagnostic.goto_next()<CR>', {silent = true})
  buf_set_keymap("n", "<leader>rn", ":lua vim.lsp.buf.rename()<CR>", {silent = true})
  -- Setup lspconfig.
  require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
  client.resolved_capabilities.execute_command = true -- client.commands = require('sqls').commands
  -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
end

function M.default(configs, server)

  ServerName = server
  local icons = {
    Class = " ",
    Color = " ",
    Constant = " ",
    Constructor = " ",
    Enum = "了 ",
    EnumMember = " ",
    Field = " ",
    File = " ",
    Folder = " ",
    Function = " ",
    Interface = "ﰮ ",
    Keyword = " ",
    Method = "ƒ ",
    Module = " ",
    Property = " ",
    Snippet = "﬌ ",
    Struct = " ",
    Text = " ",
    Unit = " ",
    Value = " ",
    Variable = " ",
  }
  local kinds = vim.lsp.protocol.CompletionItemKind
  for i, kind in ipairs(kinds) do
    kinds[i] = icons[kind] or kind
  end
  vim.cmd [[autocmd! ColorScheme * highlight NormalFloat guibg=#1f2335]]
  vim.cmd [[autocmd! ColorScheme * highlight FloatBorder guifg=white guibg=#1f2335]]
  local custom_config = {
    root_dir = M.custom_cwd,
    on_init = M.custom_on_init,
    on_attach = M.on_attach,
    capabilities = M.custom_capabilities(),
    handlers = {
      ["textDocument/publishDiagnostics"] = vim.lsp.with(
      vim.lsp.diagnostic.on_publish_diagnostics, {
	virtual_text = true,
	underline = true,
      }),
    },
    flags = {
      debounce_text_changes = 150,
    },
  }
  vim.diagnostic.config({
    virtual_text = {
      -- prefix = '●', -- Could be '■', '●', '▎', 'x'
    }
  })
  if configs ~= nil then
    for key, value in pairs(configs.custom_config()) do
      custom_config[key] = value
    end
  end
  return custom_config
end

return M
