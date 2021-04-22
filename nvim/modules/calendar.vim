au BufRead,BufNewFile *.wiki set filetype=vimwiki
function! ToggleCalendar()
  execute ":CalendarT"
  if exists("g:calendar_open")
    if g:calendar_open == 1
      execute "q"
      unlet g:calendar_open
    else
      g:calendar_open = 1
    end
  else
    let g:calendar_open = 1
  end
endfunction
:autocmd FileType vimwiki map <C-c> :call ToggleCalendar() <CR>
