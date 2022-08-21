local helpers = require('sheena.utils.helpers')
helpers.keymaps('n', '<leader>vn', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
helpers.keymaps('n', '<leader>vf', ':NvimTreeFocus<CR>', { noremap = true, silent = true })
require'nvim-tree'.setup ({
  -- auto_close = true,
  open_on_setup = false,
  update_cwd = true,
  disable_netrw = true,
  view = {
    side = 'right',
    width = 40,
    number = false,
    relativenumber = false
    -- auto_resize = false
  },
  diagnostics = {
    enable = true,
    icons = {
      hint = "",
      info = "",
      warning = "",
      error = "",
    }
  },
  update_focused_file = {
    enable      = true,
    update_cwd  = false,
    ignore_list = {}
  },
  git = {
    enable = true,
    ignore = true,
    timeout = 500,
  },
  trash = {
    cmd = "trash",
    require_confirm = true
  },
})
vim.cmd("autocmd BufWinEnter NvimTree setlocal cursorline")
function NvimTreeToggleAndFindFile()
  local nt_lib = require'nvim-tree.lib'
  if nt_lib.win_open() then
    nt_lib.close()
  else
    require'nvim-tree'.find_file(true)
  end
end
