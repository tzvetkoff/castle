"
" ~/.vimrc
"
" Author: Latchezar "Polizei" Tzvetkoff <latchezar@tzvetkoff.net>
" vim: ft=vim ts=2 et
"

" Do nothing if started as `evim'
if v:progname =~? "evim"
  finish
endif

" Pathogen
try
  runtime bundle/vim-pathogen/autoload/pathogen.vim
  call pathogen#infect()
  call pathogen#helptags()
catch
endtry

" Use Vim settings, rather then Vi settings (much better!)
" This must be first, because it changes other options as a side effect.
set nocompatible

" Always show the status bar
set laststatus=2

" UTF-8 FTW
set encoding=utf-8

" Force 256 colors in terminals
set t_Co=256

" Allow backspacing over everything in insert mode
set backspace=indent,eol,start

set nobackup        " do not keep a backup file, use versions instead
set history=50      " keep 50 lines of command line history
set ruler           " show the cursor position all the time
set showcmd         " display incomplete commands
set incsearch       " do incremental searching
set tabstop=4       " set hard tab to 4 spaces
set softtabstop=4   " and soft tab too
set noexpandtab     " never expand tabs (hence the spaces in this vimrc)
set textwidth=0     " don't enforce text width
set wrapmargin=0    " don't enforce text wrap
set cursorline      " highlight current line
set nofoldenable    " disable code folding

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" Disable the mouse.
if has('mouse')
  set mouse=
endif

" Switch syntax highlighting on.
syntax on

" Dark background.
set background=dark

" Use 256 colors for solarized.
let g:solarized_termcolors=256

" Set color scheme.
colorscheme solarized

" Also use solarized for airline.
let g:airline_theme = 'solarized'

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

" Make it behave like most ides out there
set completeopt=longest,menuone

" <C-S> completion (much like every other ide)
function! Completion_CtrlSpace()
  if pumvisible() || &omnifunc == ''
    return "\<C-n>"
  elseif col('.') > 1 && strpart(getline('.'), col('.') - 2, 3) =~ '^\w'
    return "\<C-p>"
  endif
endfunction
inoremap <Nul> <C-R>=Completion_CtrlSpace()<CR>
"inoremap <expr> <C-Space> pumvisible() \|\| &omnifunc == '' ?
"\ "\<lt>C-n>" :
"\ "\<lt>C-x>\<lt>C-o><c-r>=pumvisible() ?" .
"\ "\"\\<lt>c-n>\\<lt>c-p>\\<lt>c-n>\" :" .
"\ "\" \\<lt>bs>\\<lt>C-n>\"\<CR>"
"imap <C-@> <C-Space>

" Search toggle
"nnoremap <silent> <C-s> :set hlsearch!<CR>

" Smart HOME key
function! SmartHome()
  let s:col = col(".")
  normal! ^
  if s:col == col(".")
    normal! 0
  endif
endfunction
nnoremap <silent> <Home> :call SmartHome()<CR>
inoremap <silent> <Home> <C-O>:call SmartHome()<CR>

" Tab navigation - command mode
map <D-1> :tabn 1<CR>
map <D-2> :tabn 2<CR>
map <D-3> :tabn 3<CR>
map <D-4> :tabn 4<CR>
map <D-5> :tabn 5<CR>
map <D-6> :tabn 6<CR>
map <D-7> :tabn 7<CR>
map <D-8> :tabn 8<CR>
map <D-9> :tabn 9<CR>

" Tab navigation - insert mode
map! <D-1> <C-O>:tabn 1<CR>
map! <D-2> <C-O>:tabn 2<CR>
map! <D-3> <C-O>:tabn 3<CR>
map! <D-4> <C-O>:tabn 4<CR>
map! <D-5> <C-O>:tabn 5<CR>
map! <D-6> <C-O>:tabn 6<CR>
map! <D-7> <C-O>:tabn 7<CR>
map! <D-8> <C-O>:tabn 8<CR>
map! <D-9> <C-O>:tabn 9<CR>

" Line numbers
set number

" Disable .viminfo
set viminfo=

" NERDTree
map <C-r> :NERDTreeToggle<CR>
