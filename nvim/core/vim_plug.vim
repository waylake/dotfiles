call plug#begin('~/.config/nvim/vim_plug')

Plug 'scrooloose/nerdcommenter'
Plug 'jpalardy/vim-slime', { 'for': 'python' }
Plug 'hanschen/vim-ipython-cell', { 'for': 'python' }
Plug 'brooth/far.vim'
Plug 'kalekundert/vim-coiled-snake'
Plug 'Konfekt/FastFold'
" tagbar
Plug 'majutsushi/tagbar'
Plug 'pangloss/vim-javascript'
" javascript
Plug 'vim-scripts/jsbeautify'



call plug#end()

" NERD Commenter
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1
" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1
" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'
" Set a language to use its alternate delimiters by default
let g:NERDAltDelims_java = 1
" Add your own custom formats or override the defaults
let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }
" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1
" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1

" javascript setting
let g:javascript_plugin_jsdoc = 1
