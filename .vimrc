"
" ~/.vimrc
"
" Author: Latchezar Tzvetkoff <latchezar@tzvetkoff.net>
" vim: filetype=vim tabstop=2 softtabstop=2 shiftwidth=2 expandtab
"

" Pathogen.
try
  runtime bundle/vim-pathogen/autoload/pathogen.vim
  call pathogen#infect()
  call pathogen#helptags()
catch
endtry

" Options.
set nocompatible                " force vim mode
set laststatus=2                " always show the status bar
set encoding=utf-8              " default to utf-8
set t_Co=256                    " force 256 colors
set backspace=indent,eol,start  " allow backspacing over everything
set nobackup                    " do not keep a backup file, use versions instead
set history=50                  " keep 50 lines of command line history
set ruler                       " show the cursor position all the time
set showcmd                     " display incomplete commands
set incsearch                   " do incremental searching
set tabstop=4                   " set hard tab to 4 spaces
set softtabstop=4               " and soft tab to 4 spaces
set shiftwidth=4                " and shift width too
set noexpandtab                 " default to tabs instead of spaces
set textwidth=0                 " don't enforce text width
set wrapmargin=0                " don't enforce text wrap
set number                      " show line numbers
set cursorline                  " highlight current line
set nofoldenable                " disable code folding
set viminfo=                    " disable .viminfo

" Disable the mouse.
if has("mouse")
  set mouse=
endif

" Syntax highlighting.
syntax on

" Color scheme.
set background=dark
let g:solarized_transparent = 1
let g:solarized_trailing = 1
let g:solarized_termcolors = 256
let g:airline_theme = "solarized"
colorscheme solarized

" Only do this part when compiled with support for autocommands.
if has("autocmd")
  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
    au!

    " When editing a file, always jump to the last known cursor position.
    " Don't do it when the position is invalid or when inside an event handler
    " (happens when dropping a file on gvim).
    " Also don't do it when the mark is in the first line, that is the default
    " position when opening a file.
    autocmd BufReadPost *
      \ if line("'\"") > 1 && line("'\"") <= line("$") |
      \   exe "normal! g`\"" |
      \ endif

    " Load autocomplete stuff.
    autocmd FileType *
      \ execute "setlocal complete+=k/usr/share/vim/".
      \   "vim".v:version[0].v:version[2]."/syntax/".getbufvar("%", "current_syntax").".vim"
  augroup END
else
  set autoindent        " always set autoindenting on
endif

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis
endif

" Make it behave like most ides out there.
set completeopt=longest,menuone

" <C-S> completion (much like every other ide.)
function! Completion_CtrlSpace()
  if pumvisible() || &omnifunc == ""
    return "\<C-n>"
  elseif col(".") > 1 && strpart(getline("."), col(".") - 2, 3) =~ "^\w"
    return "\<C-p>"
  endif
endfunction
inoremap <Nul> <C-R>=Completion_CtrlSpace()<CR>

" Smart HOME key.
function! SmartHome()
  let s:col = col(".")
  normal! ^
  if s:col == col(".")
    normal! 0
  endif
endfunction
nnoremap <silent> <Home> :call SmartHome()<CR>
inoremap <silent> <Home> <C-O>:call SmartHome()<CR>

" Write as root.
function WriteAsRoot()
  if bufname("%") != ""
    silent execute "write !sudo tee >/dev/null ".bufname("%")
    edit!
  endif
endfunction
command W call WriteAsRoot()
cmap w!! w !sudo tee >/dev/null %

" GitGutter.
let g:gitgutter_enabled = 1
let g:gitgutter_sign_allow_clobber = 1

" Syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

" NERDTree.
map <C-r> :NERDTreeToggle<CR>
let NERDTreeMapOpenInTab = '<ENTER>'

" CtrlP.
let g:ctrlp_dotfiles = 1
let g:ctrlp_prompt_mappings = {
  \ 'AcceptSelection("e")': ['<2-LeftMouse>'],
  \ 'AcceptSelection("t")': ['<cr>'],
  \ }
