fu! SessionCreate()
  if !isdirectory(expand("~/.vim/sessions"))
    execute "call mkdir(expand('~/.vim/sessions', 'p'))"
  endif
  execute 'mksession ~/.vim/sessions/' . split(getcwd(), '/')[-1] . '.vim'
endfunction

command SessCreate call SessionCreate()

if !isdirectory(expand("~/.vim/sessions"))
  execute "call mkdir(expand('~/.vim/sessions', 'p'))"
endif

" execute 'mksession ~/.vim/sessions/' . split(getcwd(), '/')[-1] . '.vim'

fu! SessionSave()
  if filewritable(expand('~/.vim/sessions/' . split(getcwd(), '/')[-1] . '.vim'))
    execute 'mksession! ~/.vim/sessions/' . split(getcwd(), '/')[-1] . '.vim'
  endif
endfunction

fu! SessionreStore()
  " let l:session_file = '~/.vim/sessions/' . split(getcwd(), '/')[-1] . '.vim'
  if filereadable(expand(session_file))
    execute 'source ~/.vim/sessions/' .  split(getcwd(), '/')[-1] . '.vim'

    if bufexists(1)
      for l in range(1, bufnr('$'))
        if bufwinnr(l) == -1
          exec 'sbuffer ' . l
        endif
      endfor
    endif
  endif
endfunction

if bufexists(1)
  for l in range(1, bufnr('$'))
    if bufwinnr(l) == -1
      exec 'sbuffer ' . l
    endif
  endfor
endif


