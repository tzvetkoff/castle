" ~/.vimrc
" Author: Latchezar Tzvetkoff <latchezar@tzvetkoff.net>

" Pathogen. {{{
try
  runtime bundle/vim-pathogen/autoload/pathogen.vim
  call pathogen#infect()
  call pathogen#helptags()
catch
endtry
" }}}

" Options. {{{
set nocompatible                                " force vim mode
set laststatus=2                                " always show the status bar
set encoding=utf-8                              " default to utf-8
set t_Co=256                                    " force 256 colors
set backspace=indent,eol,start                  " allow backspacing over everything
set nobackup                                    " do not keep a backup file, use versions instead
set history=50                                  " keep 50 lines of command line history
set ruler                                       " show the cursor position all the time
set showcmd                                     " display incomplete commands
set incsearch                                   " do incremental searching
set tabstop=4                                   " set hard tab to 4 spaces
set softtabstop=4                               " and soft tab to 4 spaces
set shiftwidth=4                                " and shift width too
set noexpandtab                                 " default to tabs instead of spaces
set textwidth=0                                 " don't enforce text width
set wrapmargin=0                                " don't enforce text wrap
set number                                      " show line numbers
set cursorline                                  " highlight current line
set nofoldenable                                " disable code folding
set viminfo=                                    " disable .viminfo
set list                                        " list invisible characters
if v:version < 800
  set listchars=eol:¬,tab:🠂\ ,nbsp:_              " old versions can't list space
else
  set listchars=eol:¬,tab:🠂\ ,space:·,nbsp:_      " but newer do
endif

" Disable the mouse.
if has("mouse")
  set mouse=
endif
" }}}

" Color scheme. {{{
syntax on
set background=dark
let g:solarized_transparent = 1
let g:solarized_trailing = 1
let g:solarized_termcolors = 256
let g:airline_theme = "solarized"
colorscheme solarized
" }}}

" Indentation. {{{
filetype plugin indent on

" File-based indentation settings.
autocmd FileType c,cpp,cxx,h,hpp,hxx setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
autocmd FileType sh setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
autocmd FileType rb setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
autocmd FileType vim setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
" }}}

" Completion. {{{
set completeopt=longest,menuone

" <C-S> completion.
function! CtrlSpaceCompletion()
  if pumvisible() || &omnifunc == ""
    return "\<C-n>"
  elseif col(".") > 1 && strpart(getline("."), col(".") - 2, 3) =~ "^\w"
    return "\<C-p>"
  endif
endfunction
inoremap <Nul> <C-R>=CtrlSpaceCompletion()<CR>

" <TAB> completion, even more like modern IDEs.
function! TabCompletion()
  let col = col('.') - 1
  if !col || getline('.')[col - 1] !~ '\k'
    return "\<tab>"
  else
    return "\<c-n>"
  endif
endfunction
inoremap <expr> <tab> TabCompletion()
inoremap <s-tab> <c-p>

" Load autocomplete stuff.
autocmd FileType *
  \ execute "setlocal complete+=k/usr/share/vim/".
  \   "vim".v:version[0].v:version[2]."/syntax/".getbufvar("%", "current_syntax").".vim"
" }}}

" File encoding stuff. {{{
function! SetEncoding(encoding, force)
  if a:force || !exists("b:auto_encoding")
    let b:auto_encoding = a:encoding
    exec "e! ++enc=".a:encoding
  endif
endfunction

command -nargs=1 SetEncoding call SetEncoding("<args>", 1)
cabbrev enc SetEncoding

autocmd BufNewFile,BufRead *.nfo set filetype=nfo | call SetEncoding("cp437", 0)
" }}}

" Tab navigation. {{{
cabbrev <expr> t getcmdtype() == ":" && getcmdline() == "t" ? "tabn" : "t"
cabbrev t tabn
for i in range(1, 99)
  execute "cmap t".i." tabn ".i
endfor

cabbrev help tab help
" }}}

" Miscellaneous commands. {{{
cmap Q q
" }}}

" Diff against the original contents. {{{
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis
endif
" }}}

" Smart HOME key. {{{
function! SmartHome()
  let s:col = col(".")
  normal! ^
  if s:col == col(".")
    normal! 0
  endif
endfunction
nnoremap <silent> <Home> :call SmartHome()<CR>
inoremap <silent> <Home> <C-O>:call SmartHome()<CR>
" }}}

" Write as root. {{{
function! WriteAsRoot()
  if bufname("%") != ""
    silent execute "write !sudo tee >/dev/null ".bufname("%")
    edit!
  endif
endfunction
command W call WriteAsRoot()
command WriteAsRoot call WriteAsRoot()
cmap w!! w !sudo tee >/dev/null %
" }}}

" Strip trailing whitespaces. {{{
function! StripTrailingWhitespaces()
  silent execute "%s/\\s\\+$//g"
endfunction
command Strip call StripTrailingWhitespaces()
" }}}

" GitGutter. {{{
let g:gitgutter_enabled = 1
let g:gitgutter_sign_allow_clobber = 1
" }}}

" ALE/Syntastic. {{{
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
" }}}

" NERDTree. {{{
map <C-r> :NERDTreeToggle<CR>
let NERDTreeMapOpenInTab = '<ENTER>'
" }}}

" CtrlP. {{{
let g:ctrlp_dotfiles = 1
let g:ctrlp_custom_ignore = {
  \ 'dir': '\v[\/](\.git|node_modules)$',
  \ }
let g:ctrlp_prompt_mappings = {
  \ 'AcceptSelection("e")': ['<2-LeftMouse>'],
  \ 'AcceptSelection("t")': ['<cr>'],
  \ }
" }}}

" Go. {{{
if v:version < 800
  let g:go_loaded_install = 1
endif
" }}}

" ----------------------------------------------------------
" vim:fen:fdm=marker:fmr={{{,}}}:fdl=0:fdc=1:ts=2:sts=2:sw=2
