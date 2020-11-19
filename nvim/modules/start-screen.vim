let g:startify_session_dir = '~/.config/nvim/session'
let g:startify_lists = [
          \ { 'type': 'dir',       'header': ['   Current Directory '. getcwd()] },
          \ { 'type': 'sessions',  'header': ['   Sessions']       },
          \ { 'type': 'bookmarks', 'header': ['   Bookmarks']      },
          \ ]
let g:startify_bookmarks = [
            \ { 'i': '~/.config/nvim/init.vim' },
            \ { 'z': '~/.zshrc' },
            \ { 's': '~/.config/nvim/modules/start-screen.vim' },
            \ { 't': '~/.config/nvim/general/settings.vim' },
            \ { 'm': '~/.config/nvim/keys/mappings.vim' },
            \ { 'w': '~/vimwiki' },
            \ { 'p': '~/.config/nvim/vim-plug/plugins.vim' },
            \ '~/code/lakasir_organizations/lakasir',
            \ '~/code/Fronline/hotel-reactjs',
            \ '~/code/Fronline/hotel-cms',
            \ '~/code/Fronline/hotel-backoffice',
            \ '~/code/myproject/petshopapp',
            \ '~/code',
            \ ]
let g:startify_session_autoload = 1
let g:startify_change_to_vcs_root = 1
let g:startify_fortune_use_unicode = 1
let g:startify_session_persistence = 1
let g:startify_enable_special = 0
