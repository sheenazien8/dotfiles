function! GitBranch()
  return system("git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n'")
endfunction

function! StatuslineGit()
  let l:branchname = GitBranch()
  return strlen(l:branchname) > 0?'  '.l:branchname.' ':''
endfunction

function! DrawStatusline()
    let currentmode = mode()

    hi User1 ctermbg=black ctermfg=darkgrey
    hi User6 ctermbg=darkgreen ctermfg=green
    let mode_name='NORMAL'

    " Check for (any) visual mode
    if currentmode ==? 'v' || currentmode == '[MOVE CURSOR INSIDE THESE BRACKETS AND HIT ciSINGLEQUOTE<Ctrl-q><Ctrl-v><Esc>]' 
        let mode_name='VISUAL'
    elseif currentmode == 'i'
        let mode_name='INSERT'
    elseif currentmode == 'R'
        let mode_name='REPLACE'
    endif

    return mode_name
endfunction

set hidden  " allow buffer switching without saving
" set showtabline=2  " always show tabline
set laststatus=2
set statusline=
set statusline+=%{DrawStatusline()}
set statusline+= 
set statusline+=%#PmenuSel#
set statusline+=%{StatuslineGit()}
set statusline+=%#LineNr#
set statusline+=\ %f
set statusline+=%m\
set statusline+=%=
set statusline+=%#CursorColumn#
set statusline+=\ %y
set statusline+=\ %{&fileencoding?&fileencoding:&encoding}
set statusline+=\[%{&fileformat}\]
set statusline+=\ %p%%
set statusline+=\ %l:%c
set statusline+=\

