local helpers = require('sheena.utils.helpers')
vim.cmd 'autocmd BufWinEnter,WinEnter term://* startinsert'
local opts = {noremap = true}
helpers.keymaps('t', 'jk', [[<C-\><C-n>]], opts)
helpers.keymaps('t', '<c-q>', '<C-\\><C-n>:bd!<CR>', opts)


vim.api.nvim_set_keymap("n", "<c-t>", ":botright split term://zsh | resize " .. (vim.fn.winheight(".") * 25/100) .. "<CR>", {noremap = true, silent = true})
-- function! s:get_visual_selection()
--     " Why is this not a built-in Vim script function?!
--     let [line_start, column_start] = getpos("'<")[1:2]
--     let [line_end, column_end] = getpos("'>")[1:2]
--     let lines = getline(line_start, line_end)
--     if len(lines) == 0
--         return ''
--     endif
--     let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
--     let lines[0] = lines[0][column_start - 1:]
--     return join(lines, "\n")
-- endfunction

function VimTinker()
  local _, lnum1, col1, _ = unpack(vim.fn.getpos("'<"))
  local _, lnum2, col2, _ = unpack(vim.fn.getpos("'>"))
  local lines = vim.fn.getline(lnum1, lnum2)
  vim.cmd("!lakasir php artisan tinker --execute '" .. vim.fn.join(lines) .. "'")
end
