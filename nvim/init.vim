set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
" source ~/.vimrc
source $HOME/.config/nvim/vim-plug/plugins.vim
source $HOME/.config/nvim/general/settings.vim
source $HOME/.config/nvim/keys/mappings.vim
source $HOME/.config/nvim/modules/tagbar.vim
source $HOME/.config/nvim/themes/onedark.vim
source $HOME/.config/nvim/modules/lightline.vim
source $HOME/.config/nvim/modules/ale.vim
source $HOME/.config/nvim/modules/dog-generate.vim
source $HOME/.config/nvim/modules/php-doc.vim
source $HOME/.config/nvim/modules/phpunit.vim
source $HOME/.config/nvim/modules/phpactor.vim
source $HOME/.config/nvim/modules/vimwiki.vim
source $HOME/.config/nvim/modules/calendar.vim
source $HOME/.config/nvim/modules/coc.vim
source $HOME/.config/nvim/modules/nerdrw.vim
source $HOME/.config/nvim/modules/fzf.vim
source $HOME/.config/nvim/modules/jsx-improve.vim
source $HOME/.config/nvim/modules/tmux-navigator.vim

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

execute 'mksession ~/.vim/sessions/' . split(getcwd(), '/')[-1] . '.vim'

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

if filereadable(expand(session_file))
  " let l:session_file = '~/.vim/sessions/' . split(getcwd(), '/')[-1] . '.vim'
  execute 'source ~/.vim/sessions/' .  split(getcwd(), '/')[-1] . '.vim'
endif

if bufexists(1)
  for l in range(1, bufnr('$'))
    if bufwinnr(l) == -1
      exec 'sbuffer ' . l
    endif
  endfor
endif
