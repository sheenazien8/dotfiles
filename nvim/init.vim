lua << EOF
require('sheena')
EOF

let g:vimwiki_list = [{'path': '~/vimwiki/',
                      \ 'syntax': 'markdown', 'ext': '.md'}]
let g:user_emmet_mode='a'    "enable all function in all mode.
let g:user_emmet_leader_key=','

let g:user_emmet_mode='n,v'    "only enable normal mode functions.

augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
augroup END

" let s:hidden_all = 1
" function! ToggleHiddenAll()
"     if s:hidden_all  == 0
"         let s:hidden_all = 1
"         set noruler
"         set laststatus=3
"         set showmode
"     else
"         let s:hidden_all = 0
"         set ruler
"         set laststatus=3
"         set noshowmode
"     endif
" endfunction
"
" nnoremap <S-h> :call ToggleHiddenAll()<CR>
set cursorline
highlight clear CursorLine
highlight CursorLineNR ctermbg=red
set laststatus=3
