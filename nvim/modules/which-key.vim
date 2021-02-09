" Map leader to which_key
nnoremap <silent> <leader> :silent WhichKey '<Space>'<CR>
vnoremap <silent> <leader> :silent <c-u> :silent WhichKeyVisual '<Space>'<CR>

" Create map to add keys to
let g:which_key_map =  {}
" Define a separator
let g:which_key_sep = '→'
" set timeoutlen=100

" Not a fan of floating windows for this
let g:which_key_use_floating_win = 0

" Change the colors if you want
highlight default link WhichKey          Operator
highlight default link WhichKeySeperator DiffAdded
highlight default link WhichKeyGroup     Identifier
highlight default link WhichKeyDesc      Function

" Hide status line
autocmd! FileType which_key
autocmd  FileType which_key set laststatus=0 noshowmode noruler
  \| autocmd BufLeave <buffer> set laststatus=2 noshowmode ruler

" Single mappings
let g:which_key_map['/'] = [ ':Commentary'  , 'comment' ]
let g:which_key_map['p'] = [ ':Files'                     , 'search files' ]
let g:which_key_map['h'] = [ '<C-W>s'                     , 'split below']
let g:which_key_map['v'] = [ '<C-W>v'                     , 'split right']
let g:which_key_map['`'] = [ ':botright 15 sp term://zsh'                       , 'terminal' ]
let g:which_key_map['d'] = [ ':call PhpDocSingle()'                       , 'dog-generate' ]
let g:which_key_map['g'] = [ ':G'                       , 'Stag Edited Files' ]
let g:which_key_map[' '] = [ ':nohlsearch'                       , 'No Highlight Search' ]
let g:which_key_map['f'] = [ ':CocCommand explorer --preset floating' , 'Floating file in explorer' ]
let g:which_key_map['k'] = [ '' , 'Open PHP Manual' ]

" r for phpactor
let g:which_key_map.r = {
      \ 'name' : '+phpactor' ,
      \ 'a' : [':call phpactor#ContextMenu()/'     , 'Context Menu'],
      \ 'cc' : [':call PhpConstructorArgumentMagic()/'     , 'Fix Construction By Magic'],
      \ 'cl' : [':call phpactor#ClassNew()/', 'Class New'],
      \ 't' : [':PhpactorTransform', 'Transform File'],
      \ 'ee' : [':call phpactor#ExtractExpression(v:false)/'     , 'Extract Expression'],
      \ 'ei' : [':call phpactor#ClassInflect()/'     , 'Clas Inflect'],
      \ 'em' : [':call phpactor#ExtractMethod()/'     , 'Extract Method'],
      \ 'fn' : [':PHPModify("fix_namespace_class_name")', 'Fix Namespace Class'],
      \ 'fr' : [':PhpactorFindReferences', 'Find References'],
      \ 'ga' : [':PhpactorGenerateAccessors', 'Generate Accessor'],
      \ 'ic' : [':call PHPModify("implement_contracts")/'     , 'Implements Contracts'],
      \ 'im' : [':PhpactorImportMissingClasses', 'Import Missing Class'],
      \ 'is' : [':PhpactorImportClass', 'Import Class'],
      \ 'mc' : [':call PHPMoveClass()/', 'Move Class'],
      \ 'md' : [':call PHPMoveDir()/', 'Move Dir'],
      \ 'mp' : [':call PHPModify("add_missing_properties")/'     , 'Add Missing Property'],
      \ 'nv' : [':PhpactorNavigate', 'Navigate'],
      \ 're' : [':PHPModify("replace_references")', 'Replace References'],
      \}

" s is for search
let g:which_key_map.s = {
      \ 'name' : '+search' ,
      \ '/' : [':History/'     , 'history'],
      \ ';' : [':Commands'     , 'commands'],
      \ 'a' : [':Ag'           , 'text Ag'],
      \ 'b' : [':BLines'       , 'current buffer'],
      \ 'B' : [':Buffers'      , 'open buffers'],
      \ 'c' : [':Commits'      , 'commits'],
      \ 'C' : [':BCommits'     , 'buffer commits'],
      \ 'f' : [':Files'        , 'files'],
      \ 'g' : [':GFiles'       , 'git files'],
      \ 'G' : [':GFiles?'      , 'modified git files'],
      \ 'h' : [':History'      , 'file history'],
      \ 'H' : [':History:'     , 'command history'],
      \ 'l' : [':Lines'        , 'lines'] ,
      \ 'm' : [':Marks'        , 'marks'] ,
      \ 'M' : [':Maps'         , 'normal maps'] ,
      \ 'p' : [':Helptags'     , 'help tags'] ,
      \ 'P' : [':Tags'         , 'project tags'],
      \ 's' : [':Snippets'     , 'snippets'],
      \ 'S' : [':Colors'       , 'color schemes'],
      \ 't' : [':Rg'           , 'text Rg'],
      \ 'T' : [':BTags'        , 'buffer tags'],
      \ 'w' : [':Windows'      , 'search windows'],
      \ 'y' : [':Filetypes'    , 'file types'],
      \ 'z' : [':FZF'          , 'FZF'],
      \ }

" Register which key map
call which_key#register('<Space>', "g:which_key_map")
