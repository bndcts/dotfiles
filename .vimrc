set nocompatible

" Editor Appearance
syntax enable
colorscheme torte
highlight Normal ctermbg=235
set number
set ruler
set visualbell
set scrolloff=7

" Text Styling, Formatting
set wrap
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set noshiftround
set autoindent
set smartindent

" Misc
set hidden
set history=500

set confirm

" Search
set hlsearch
set incsearch
set ignorecase smartcase

set ttyfast
set laststatus=2
set listchars=tab:▸\ ,eol:¬
set showmode
set showcmd

if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g'\"" | endif
endif
