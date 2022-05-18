require('Comment').setup{
  pre_hook = function(ctx)
    local U = require 'Comment.utils'

    local location = nil
    if ctx.ctype == U.ctype.block then
      location = require('ts_context_commentstring.utils').get_cursor_location()
    elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
      location = require('ts_context_commentstring.utils').get_visual_start_location()
    end

    return require('ts_context_commentstring.internal').calculate_commentstring {
      key = ctx.ctype == U.ctype.line and '__default' or '__multiline',
      location = location,
    }
  end,
}
-- local ft = require('Comment.ft')
-- ft.set('blade', '{{-- %s  --}}')

require('GoToWorkspace')
require('gitsigns').setup({
  signcolumn = false;
})
-- vim.cmd 'autocmd BufNewFile,BufRead *.blade.php set filetype=blade'
-- vim.cmd 'autocmd BufWinEnter,WinEnter *.blade.php set filetype=html'
-- vim.cmd 'autocmd BufWinEnter,BufRead *.blade.php set syntax=html'
-- require'colorizer'.setup()
