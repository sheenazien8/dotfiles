au BufWritePost *.php silent! !eval '[ -f ".git/hooks/ctags" ] && .git/hooks/ctags' &

" python
autocmd FileType python map <buffer> <F9> :exec '!python3' shellescape(@%, 1)<CR>
autocmd FileType python imap <buffer> <F9> :exec '!python3' shellescape(@%, 1)<CR>
" PHP
autocmd FileType php map <buffer> <F9> :exec '!php' shellescape(@%, 1)<CR>
autocmd FileType php imap <buffer> <F9> :exec '!php' shellescape(@%, 1)<CR>
autocmd FileType php set iskeyword+=$
" feature test
autocmd FileType php map <buffer> <F10> :exec '!./vendor/phpunit/phpunit/phpunit'<CR>
autocmd FileType php imap <buffer> <F10> :exec '!'./vendor/phpunit/phpunit/phpunit<CR>
autocmd FileType php map <buffer> <F11> :!php artisan test<CR>

" featur test with parameters
autocmd FileType php command! -nargs=1 Tf execute "!./vendor/phpunit/phpunit/phpunit --filter" string(<q-args>)

command! -nargs=1 Silent execute ':silent !'.<q-args> | execute ':redraw!'
map <c-s> <esc>:w<cr>:Silent php-cs-fixer fix %:p --level=symfony<cr>

function! TransFormFile()
    call phpactor#Transform()
    call feedkeys('a',  'n')
endfunction

autocmd FileType php inoremap <buffer> <F1>  <Esc>:call TransFormFile()<CR>
autocmd FileType php noremap <buffer> <F1>  :PhpactorTransform<CR>

autocmd FileType php map <buffer> <F2> :PhpactorContextMenu<CR>

autocmd FileType php map <buffer> <F3> :PhpactorNavigate<CR>

autocmd FileType php map <buffer> <F4> :PhpactorImportMissingClasses<CR>

function! IPhpInsertUse()
    call phpactor#ImportClass()
    call feedkeys('a',  'n')
endfunction
autocmd FileType php inoremap <buffer> <F5>  <Esc>:call IPhpInsertUse()<CR>
autocmd FileType php noremap <buffer> <F5>  :PhpactorImportClass<CR>


function! IPhpExpandClass()
    call phpactor#ClassExpand()
    call feedkeys('a', 'n')
endfunction
autocmd FileType php inoremap <buffer> <F6>  <Esc>:call IPhpExpandClass()<CR>
autocmd FileType php noremap <buffer> <F6>  :PhpactorClassExpand<CR>

autocmd FileType php map <buffer> <F12> :PhpactorGotoDefinition<CR>

