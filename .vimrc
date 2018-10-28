"--- this is my vimrc, there are many like it but this one is mine -------

"--- neobundle stuff -----------------------------------------------------

if has('vim_starting')
  if &compatible
    set nocompatible
  endif
  set runtimepath+=~/.vim/bundle/neobundle.vim/ 
endif
call neobundle#begin(expand('~/.vim/bundle'))
NeoBundleFetch 'Shougo/neobundle.vim'

NeoBundle 'Shougo/neosnippet.vim'
NeoBundle 'Shougo/neosnippet-snippets'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'ctrlpvim/ctrlp.vim'
"NeoBundle 'flazz/vim-colorschemes'

NeoBundle 'vim-perl/vim-perl'
NeoBundle 'StanAngeloff/php.vim'
NeoBundle 'scrooloose/nerdtree'	
NeoBundle 'bling/vim-airline'
NeoBundle 'altercation/vim-colors-solarized' 
NeoBundle 'vim-airline/vim-airline-themes'

NeoBundle 'christoomey/vim-run-interactive'
NeoBundle 'Valloric/vim-indent-guides'

NeoBundle 'Shougo/vimshell', { 'rev' : '3787e5' }

call neobundle#end()

"--- shared code ---------------------------------------------------------

filetype plugin indent on
NeoBundleCheck	
"set t_ut=
set t_Co=256
set laststatus=2
set rtp+=/usr/local/opt/fzf

" option name default optional ———————————————— 
let g:solarized_termcolors= 16 
let g:solarized_termtrans = 1 
let g:solarized_degrade = 0  
let g:solarized_bold = 1  
let g:solarized_underline = 1 
let g:solarized_italic = 1 
let g:solarized_contrast = "normal"
let g:solarized_visibility= "normal"
colorscheme solarized
set background=dark
let g:airline_theme='solarized'	
let g:airline_powerline_fonts = 1
syntax on
filetype plugin indent on

"highlight Normal ctermbg=0

"let hostname = substitute(system('hostname'), '\n', '','')

if hostname() == "koloth"
 highlight Normal ctermbg=0
endif 

set tabstop=2 shiftwidth=2 softtabstop=2 expandtab
set backspace=indent,eol,start
set nu

"--- keybindings for plugins ---------------------------------------------

nnoremap <leader>nt :NERDTreeToggle<CR>
nnoremap <leader>ri :RunInInteractiveShell<space>

"--- system specific -----------------------------------------------------

if hostname() == "koloth"  " koloth - koding vm
  " stupid patch to fix the vim-solarized dark background in koding
  highlight Normal ctermbg=0
endif
