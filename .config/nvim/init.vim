set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath

if exists('g:vscode')
  set hidden
  set ignorecase
  set smartcase
  set backspace=indent,eol,start
  set autoindent
  set nostartofline
  set ruler
  set visualbell
  set cmdheight=2
  set number
  set notimeout ttimeout ttimeoutlen=200
  set shiftwidth=4
  set softtabstop=4
  set expandtab

  map Y y$
  nnoremap <C-L> :nohl<CR><C-L>
else
  source ~/.vimrc
endif
