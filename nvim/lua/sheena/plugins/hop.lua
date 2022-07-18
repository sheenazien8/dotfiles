local helpers = require('sheena.utils.helpers')
require'hop'.setup()

helpers.keymaps('n', '<space>ll', ':HopLine<CR>', { noremap = true, silent = true })
helpers.keymaps('v', '<space>ll', '<cmd>HopLine<CR>', { noremap = true, silent = true })
helpers.keymaps('n', '<space>lc', ':HopChar1<CR>', { noremap = true, silent = true })
helpers.keymaps('v', '<space>lc', '<cmd>HopChar1<CR>', { noremap = true, silent = true })

