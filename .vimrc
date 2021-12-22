set nocompatible
filetype off

syntax on

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'

Plugin 'tpope/vim-fugitive'
Plugin 'L9'
Plugin 'godlygeek/tabular'
Plugin 'plasticboy/vim-markdown'
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
Plugin 'wakatime/vim-wakatime'

call vundle#end()
filetype plugin indent on

" Disable folding "
let g:vim_markdown_folding_disabled=1
