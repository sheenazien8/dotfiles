local helpers = require('sheena.utils.helpers')
require'hop'.setup()

helpers.keymaps('n', '<space>l', ':HopLine<CR>', { noremap = true, silent = true })
helpers.keymaps('v', '<space>l', '<cmd>HopLine<CR>', { noremap = true, silent = true })
helpers.keymaps('n', '<space>c', ':HopChar1<CR>', { noremap = true, silent = true })
helpers.keymaps('v', '<space>c', '<cmd>HopChar1<CR>', { noremap = true, silent = true })

