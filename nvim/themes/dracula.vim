" onedark.vim override: Don't set a background color when running in a terminal;
hi Comment cterm=italic

" syntax enable
colorscheme dracula
let g:dracula_italic = 0
color dracula
" let g:php_var_selector_is_identifier = 1
let php_sql_query=1
if (has("termguicolors"))
    " set termguicolors
    " hi LineNr ctermbg=NONE guibg=NONE
    hi! Normal ctermbg=none ctermfg=none guifg=none guibg=none
endif
