lua << EOF
require('sheena')
EOF

let g:vimwiki_list = [{'path': '~/vimwiki/',
                      \ 'syntax': 'markdown', 'ext': '.md'}]
let g:user_emmet_mode='a'    "enable all function in all mode.
let g:user_emmet_leader_key=','

let g:user_emmet_mode='n,v'    "only enable normal mode functions.

let g:homestead = ""
function ConnectToHomestead()
  let g:homestead = "mysql://homestead:secret@192.168.56.56/" + input("database? ")
endfunction

augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
augroup END

set cursorline
highlight clear CursorLine
highlight CursorLineNR ctermbg=red
set laststatus=3

" let &lines += 1
"
" function! s:cmdline(key) abort
"   let &lines += 1 * (a:key ==# ':' ? -1 : 1)
"   redraw
"   return a:key
" endfunction
"
" nnoremap <expr><silent> :Telescope commands<CR>
" cnoremap <expr><silent> <cr> <sid>cmdline("\<cr>")
" cnoremap <expr><silent> <esc> <sid>cmdline("\<esc>")
