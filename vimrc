" Activate Pathogen
runtime bundle/pathogen/autoload/pathogen.vim
call pathogen#infect()
call pathogen#helptags()

" Activate solarized color scheme
syntax enable
set background=dark
colorscheme solarized

" Fix the backspace key
set backspace=indent,eol,start

" Configure indenting
set expandtab
set shiftwidth=2
set softtabstop=2

" Coding environment options
set nu

" Enable system clipboard
set clipboard=unnamed
