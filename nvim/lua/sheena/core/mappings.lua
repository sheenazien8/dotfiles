local helpers = require('sheena.utils.helpers')
vim.g.mapleader = ' '
helpers.keymaps('n', '<Space>', '<NOP>', { noremap = true, silent = true })
helpers.keymaps('n', '<leader><leader>', ':nohlsearch <CR>', { noremap = true, silent = true })

-- better resize windows
helpers.keymaps('n', '<M-j>', ':resize -2 <CR>', { noremap = true })
helpers.keymaps('n', '<M-k>', ':resize +2 <CR>', { noremap = true })
helpers.keymaps('n', '<M-h>', ':vertical resize -2 <CR>', { noremap = true })
helpers.keymaps('n', '<M-l>', ':vertical resize +2 <CR>', { noremap = true })

-- I hate escape
helpers.keymaps('i', 'jk', '<ESC>', { noremap = true })
helpers.keymaps('i', 'kj', '<ESC>', { noremap = true })
helpers.keymaps('i', 'jj', '<ESC>', { noremap = true })
helpers.keymaps('i', 'jl', '<ESC>', { noremap = true })

-- better next prev tab
helpers.keymaps('n', '<TAB>', ':bnext<CR>', { noremap = true })
helpers.keymaps('n', '<S-TAB>', ':bprev<CR>', { noremap = true })

-- better tabbing
helpers.keymaps('v', '<', '<gv', { noremap = true })
helpers.keymaps('v', '>', '>gv', { noremap = true })

-- better window navigation
helpers.keymaps('n', '<C-h>', '<C-w>h', { noremap = true })
helpers.keymaps('n', '<C-j>', '<C-w>j', { noremap = true })
helpers.keymaps('n', '<C-k>', '<C-w>k', { noremap = true })
helpers.keymaps('n', '<C-l>', '<C-w>l', { noremap = true })

-- move visual block
helpers.keymaps('v', 'J', ":m '>+1<CR>gv=gv", { noremap = true })
helpers.keymaps('v', 'K', ":m '<-2<CR>gv=gv", { noremap = true })

-- better split
helpers.keymaps('n', '<leader>sv', ':vsplit<CR>', { noremap = true })
helpers.keymaps('n', '<leader>sh', ':split<CR>', { noremap = true })

-- terminal
helpers.keymaps('n', '<leader>`', ':!tmux split-window -v -p 20 <CR> <CR>', { noremap = true })

helpers.keymaps('n', 'n', 'nzzzv', { noremap = true })
helpers.keymaps('n', 'N', 'Nzzzv', { noremap = true })

-- saving
helpers.keymaps('n', '<c-s>', '<esc>:w<cr>', {})

-- copy to clipboard
helpers.keymaps('v', '<c-c>', '"+y', {})

helpers.keymaps('n', 'ZZ', ':lua CloseWithSave()<CR>', {})


helpers.keymaps('n', ']q', ':cnext<CR>', { noremap = true })
helpers.keymaps('n', '[q', ':cprev<CR>', { noremap = true })
helpers.keymaps('n', ']cc', ':cclose<CR>', { noremap = true })
helpers.keymaps('n', '[cc', ':cclose<CR>', { noremap = true })

function Prettier()
  local cmd = vim.cmd
  local line = vim.fn.line(".")
  cmd 'silent %!prettier --stdin-filepath %'
  cmd(''..line)
end

helpers.keymaps('n', 'gp', ':lua Prettier()<CR>', { noremap = true })
