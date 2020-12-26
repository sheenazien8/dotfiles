let g:php_namespace_sort_after_insert = 1
function! IPhpExpandClass()
    call PhpExpandClass()
    call feedkeys('a', 'n')
endfunction
autocmd FileType php inoremap <buffer> <F6> <Esc>:call IPhpExpandClass()<CR>
autocmd FileType php noremap <buffer> <F6> :call PhpExpandClass()<CR>

autocmd FileType php inoremap <buffer> <F5> <Esc>:call PhpInsertUse()<CR>
autocmd FileType php noremap <buffer> <F5> :call PhpInsertUse()<CR>
