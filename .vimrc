" ~/.vimrc
" Author: Latchezar Tzvetkoff <latchezar@tzvetkoff.net>

" Pathogen. {{{
if v:version < 90000
  try
    runtime pack/w00t/opt/vim-pathogen/autoload/pathogen.vim
    call pathogen#infect()
    call pathogen#helptags()
  catch
  endtry
endif
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
set hlsearch                                    " highlight search results
set incsearch                                   " do incremental searching
set tabstop=4                                   " set hard tab to 4 spaces
set softtabstop=4                               " and soft tab to 4 spaces
set shiftwidth=4                                " and shift width too
set noexpandtab                                 " default to tabs instead of spaces
set textwidth=0                                 " don't enforce text width
set wrapmargin=0                                " don't enforce text wrap
set colorcolumn=80,100,120                      " long line markers
set number                                      " show line numbers
set cursorline                                  " highlight current line
set nofoldenable                                " disable code folding
set viminfo=                                    " disable .viminfo
set ttyfast                                     " fast redraw
set wildmenu                                    " completion menu in command mode
set spell                                       " enable spell checking
set spelllang=en                                " default to english
set spellfile=${HOME}/.vim/spell/en.utf-8.add   " local spell dict
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
vnoremap > >gv
vnoremap < <gv

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
  elseif col(".") > 1 && strpart(getline("."), col(".") - 2, 3) =~ "^\\w"
    return "\<C-p>"
  endif
endfunction
inoremap <Nul> <C-R>=CtrlSpaceCompletion()<CR>

" <TAB> completion.
function! TabCompletion()
  let col = col(".")
  let line = getline(".")
  let left = strpart(line, 0, col - 1)
  let right = strpart(line, col - 1)

  if left =~ "^\\s*$" || left =~ "\\s$"
    return "\<tab>"
  else
    return "\<c-n>"
  end
endfunction!
inoremap <expr> <tab> TabCompletion()

" <S-TAB> completion.
function! ShiftTabCompletion()
  let col = col(".")
  let line = getline(".")
  let left = strpart(line, 0, col - 1)
  let right = strpart(line, col - 1)

  if left =~ "^\\s*$" || left =~ "\\s$"
    return "\<c-d>"
  else
    return "\<c-p>"
  endif
endfunction
inoremap <expr> <s-tab> ShiftTabCompletion()

" Load autocomplete stuff.
autocmd FileType * execute "setlocal complete+=k/usr/share/vim/vim".v:version[0].v:version[2]."/syntax/".getbufvar("%", "current_syntax").".vim"
" }}}

" File type/encoding stuff. {{{
function! SetEncoding(encoding, force)
  if a:force || !exists("b:auto_encoding")
    let b:auto_encoding = a:encoding
    exec "e! ++enc=".a:encoding
  endif
endfunction

command -nargs=1 SetEncoding call SetEncoding("<args>", 1)
cabbrev <expr> enc getcmdtype() == ":" && getcmdline() == "enc" ? "SetEncoding" : "enc"

" File-based type/encoding settings.
autocmd BufNewFile,BufRead *.cnf setlocal filetype=dosini
autocmd BufNewFile,BufRead *.nfo setlocal filetype=nfo | call SetEncoding("cp437", 0)
" }}}

" Tab navigation. {{{
cabbrev <expr> t getcmdtype() == ":" && getcmdline() == "t" ? "tabn" : "t"
for i in range(1, 99)
  execute "cabbrev <expr> t".i." getcmdtype() == \":\" && getcmdline() == \"t".i."\" ? \"tabn ".i."\" : \"t".i."\""
  execute "cabbrev <expr> T".i." getcmdtype() == \":\" && getcmdline() == \"T".i."\" ? \"tabn ".i."\" : \"T".i."\""
endfor

cabbrev <expr> help getcmdtype() == ":" && getcmdline() == "help" ? "tab help" : "help"
" }}}

" Miscellaneous commands. {{{
command -nargs=* -complete=file -bang W w<bang> <args>
command -bang Q q<bang>
cabbrev <expr> Wq getcmdtype() == ":" && getcmdline() == "Wq" ? "wq" : "Wq"
cabbrev <expr> WQ getcmdtype() == ":" && getcmdline() == "WQ" ? "wq" : "WQ"
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
command WriteAsRoot call WriteAsRoot()
cabbrev <expr> w!! getcmdtype() == ":" && getcmdline() == "w!!" ? "WriteAsRoot" : "w!!"
" }}}

" Strip trailing whitespaces. {{{
function! StripTrailingWhitespaces()
  silent! execute "%s/\\s\\+$//g"
endfunction
command Strip call StripTrailingWhitespaces()
" }}}

" GitGutter. {{{
let g:gitgutter_enabled = 1
let g:gitgutter_sign_allow_clobber = 1
" }}}

" ALE. {{{
let g:ale_echo_msg_error_str = 'error'
let g:ale_echo_msg_warning_str = 'warning'
let g:ale_echo_msg_format = '[%linter%::%severity%] %s '
" }}}

" NERDTree. {{{
map <C-r> :NERDTreeToggle<CR>
let NERDTreeMapOpenInTab = "<ENTER>"
" }}}

" CtrlP. {{{
let g:ctrlp_dotfiles = 1
let g:ctrlp_custom_ignore = {
      \ "dir": "\\v[\\/](\\.git|node_modules)$",
      \ }
let g:ctrlp_prompt_mappings = {
      \ "AcceptSelection(\"e\")": ["<2-LeftMouse>"],
      \ "AcceptSelection(\"t\")": ["<cr>"],
      \ }
" }}}

" Go. {{{
if v:version < 800
  let g:go_loaded_install = 1
endif
" }}}

" ----------------------------------------------------------
" vim:fen:fdm=marker:fmr={{{,}}}:fdl=0:fdc=1:ts=2:sts=2:sw=2
