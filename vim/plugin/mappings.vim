" plugin/mappings.vim

let s:cpo_save = &cpoptions
set cpoptions&vim

" ============================================================================
" Commands
" ============================================================================

command! Q q

execute dko#MapAll({ 'key': '<F10>', 'command': 'call dkotabline#Toggle()' })

" ============================================================================
" Quick edit
" ec* - Edit closest (find upwards)
" er* - Edit from dkoproject#GetRoot()
" ============================================================================

function! s:EditClosest(file)
  let s:file = findfile(a:file, '.;')
  if empty(s:file)
    echomsg 'File not found:'  . a:file
    return
  endif
  execute 'edit ' . s:file
endfunction
nnoremap  <silent>  <Leader>eci  :<C-U>call <SID>EditClosest('.gitignore')<CR>
nnoremap  <silent>  <Leader>ecr  :<C-U>call <SID>EditClosest('README.md')<CR>

function! s:EditRoot(file)
  let s:file = dkoproject#GetFile(a:file)
  if empty(s:file)
    echomsg 'File not found:'  . a:file
    return
  endif
  execute 'edit ' . s:file
endfunction
nnoremap  <silent>  <Leader>eri  :<C-U>call <SID>EditRoot('.gitignore')<CR>
nnoremap  <silent>  <Leader>erp  :<C-U>call <SID>EditRoot('package.json')<CR>
nnoremap  <silent>  <Leader>err  :<C-U>call <SID>EditRoot('README.md')<CR>

" Not using $MYVIMRC since it varies based on (n)vim
nnoremap  <silent>  <Leader>evi   :<C-U>edit $VIM_DOTFILES/init.vim<CR>
nnoremap  <silent>  <Leader>evg   :<C-U>edit $VIM_DOTFILES/gvimrc<CR>
nnoremap  <silent>  <Leader>evl   :<C-U>edit ~/.secret/vim/vimrc.vim<CR>
nnoremap  <silent>  <Leader>evr   :<C-U>edit $VIM_DOTFILES/vimrc<CR>

nnoremap  <silent>  <Leader>em
      \ :<C-U>edit $VIM_DOTFILES/after/plugin/mappings.vim<CR>
nnoremap  <silent>  <Leader>ez   :<C-U>edit $ZDOTDIR/.zshrc<CR>

" ============================================================================
" Buffer manip
" ============================================================================

" ----------------------------------------------------------------------------
" Prev buffer with <BS> backspace in normal (C-^ is kinda awkward)
" ----------------------------------------------------------------------------

nnoremap  <special>   <BS>  <C-^>

" ============================================================================
" Window manipulation
" ============================================================================

" ----------------------------------------------------------------------------
" Navigate with ctrl+arrow (insert mode leaves user in normal)
" ----------------------------------------------------------------------------

nnoremap  <special>   <C-Left>    <C-w>h
nnoremap  <special>   <C-Down>    <C-w>j
nnoremap  <special>   <C-Up>      <C-w>k
nnoremap  <special>   <C-Right>   <C-w>l

" ----------------------------------------------------------------------------
" Cycle with tab in normal mode
" ----------------------------------------------------------------------------

nnoremap  <special>   <Tab>       <C-w>w
nnoremap  <special>   <S-Tab>     <C-w>W

" ----------------------------------------------------------------------------
" Resize (can take a count, eg. 2<S-Left>)
" ----------------------------------------------------------------------------

nnoremap  <special>   <S-Left>    <C-w><
imap      <special>   <S-Left>    <C-o><S-Left>
nnoremap  <special>   <S-Down>    <C-W>-
imap      <special>   <S-Down>    <C-o><S-Down>
nnoremap  <special>   <S-Up>      <C-W>+
imap      <special>   <S-Up>      <C-o><S-Up>
nnoremap  <special>   <S-Right>   <C-w>>
imap      <special>   <S-Right>   <C-o><S-Right>

" ============================================================================
" Mode and env
" ============================================================================

" ----------------------------------------------------------------------------
" Toggle visual/normal mode with space-space
" ----------------------------------------------------------------------------

nnoremap  <Leader><Leader>  V
vnoremap  <Leader><Leader>  <Esc>

" ----------------------------------------------------------------------------
" Back to normal mode
" ----------------------------------------------------------------------------

imap jj <Esc>
cmap jj <Esc>

" ----------------------------------------------------------------------------
" Unfuck my screen
" https://bitbucket.org/sjl/dotfiles/src/2c4aba25376c6c5cb5d4610cf80109d99b610505/vim/vimrc?at=default#cl-444
" ----------------------------------------------------------------------------

nnoremap U :<C-U>syntax sync fromstart<CR>:redraw!<CR>

" ----------------------------------------------------------------------------
" cd to current buffer's git root
" ----------------------------------------------------------------------------

nnoremap <silent>   <Leader>cr
      \ :<C-U>execute 'cd! ' . get(b:, 'dkoproject_root', getcwd())<CR>

" ----------------------------------------------------------------------------
" cd to current buffer path
" ----------------------------------------------------------------------------

nnoremap <silent>   <Leader>cd
      \ :<C-U>cd! %:h<CR>

" ----------------------------------------------------------------------------
" go up a level
" ----------------------------------------------------------------------------

nnoremap <silent>   <Leader>..
      \ :<C-U>cd! ..<CR>

" ============================================================================
" Editing
" ============================================================================

" ----------------------------------------------------------------------------
" Use gm to set a mark (since easyclip is using m for "move")
" ----------------------------------------------------------------------------

nnoremap  gm   m
vnoremap  gm   m

" ----------------------------------------------------------------------------
" Map the arrow keys to be based on display lines, not physical lines
" ----------------------------------------------------------------------------

vnoremap  <special>   <Down>      gj
vnoremap  <special>   <Up>        gk
nnoremap  <special>   <Leader>mm  :<C-U>call dkomovemode#toggle()<CR>

" ----------------------------------------------------------------------------
" Replace PgUp and PgDn with Ctrl-U/D
" ----------------------------------------------------------------------------

noremap   <special>   <PageUp>    <C-U>
noremap   <special>   <PageDown>  <C-D>
" same in insert mode, but stay in insert mode (needs recursive)
imap      <special>   <PageUp>    <C-o><PageUp>
imap      <special>   <PageDown>  <C-o><PageDown>

" ----------------------------------------------------------------------------
" Start/EOL
" ----------------------------------------------------------------------------

" Easier to type, and I never use the default behavior.
" From https://bitbucket.org/sjl/dotfiles/
" default is {count}from top line in visible window
noremap   H   ^
" default is {count}from last line in visible window
noremap   L   g_

" ----------------------------------------------------------------------------
" Reselect visual block after indent
" ----------------------------------------------------------------------------

vnoremap  <   <gv
vnoremap  >   >gv

" ----------------------------------------------------------------------------
" Sort lines (use unix sort)
" https://bitbucket.org/sjl/dotfiles/src/2c4aba25376c6c5cb5d4610cf80109d99b610505/vim/vimrc?at=default#cl-288
" ----------------------------------------------------------------------------

if dko#IsPlugged('vim-textobj-indent')
  " Auto select indent-level and sort
  nnoremap  <Leader>s   vii:!sort<CR>
else
  " Auto select paragraph (bounded by blank lines) and sort
  nnoremap  <Leader>s   vip:!sort<CR>
endif
" Sort selection (no clear since in visual)
vnoremap  <Leader>s   :!sort<CR>

" ----------------------------------------------------------------------------
" Uppercase / lowercase word
" ----------------------------------------------------------------------------

" mark Q, visual, inner-word case, back to mark (don't change cursor position)
nnoremap  <Leader>l   mQviwu`Q
nnoremap  <Leader>u   mQviwU`Q

" ----------------------------------------------------------------------------
" Join lines without space (and go to first char line that was merged up)
" ----------------------------------------------------------------------------

nnoremap  <Leader>j   VjgJl

" ----------------------------------------------------------------------------
" Clean up whitespace
" ----------------------------------------------------------------------------

nnoremap  <Leader>ws  :<C-U>call dkowhitespace#clean()<CR>

" ----------------------------------------------------------------------------
" Horizontal rule
" ----------------------------------------------------------------------------

call dkorule#map('_')
call dkorule#map('-')
call dkorule#map('=')
call dkorule#map('#')
call dkorule#map('*')
call dkorule#map('%')

" ============================================================================

let &cpoptions = s:cpo_save
unlet s:cpo_save
