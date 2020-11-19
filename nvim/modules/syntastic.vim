let g:syntastic_always_populate_loc_list = 0
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 1
" Syntastic configuration for PHP
let g:syntastic_php_checkers = ['php']
" let g:syntastic_php_phpcs_exec = '/home/sheenazien/.config/composer/vendor/bin/phpcs'
" let g:syntastic_php_phpcs_args = '--standard=psr2'
" let g:syntastic_php_phpmd_exec = './bin/phpmd'
" let g:syntastic_php_phpmd_post_args = 'cleancode,codesize,controversial,design,unusedcode'

"A list of regexes for phpcs messages to ignore. I don't care about any of
"these detections.
let g:syntastic_quiet_messages = { "regex": 'Missing @return\|Missing parameter comment\|Missing class doc comment\|Missing file doc comment' }

let g:syntastic_python_checkers=['flake8']

