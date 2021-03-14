" onedark.vim override: Don't set a background color when running in a terminal;
hi Comment cterm=italic

syntax enable
" let g:gruvbox_contrast_dark = 'hard'
let g:gruvbox_invert_selection= '0'
colorscheme gruvbox
let g:php_var_selector_is_identifier = 1
let php_sql_query=1
if (has("termguicolors"))
    " set termguicolors
    hi! Normal ctermbg=none ctermfg=none guifg=none guibg=none
endif
