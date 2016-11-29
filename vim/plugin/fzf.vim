" plugin/fzf.vim
scriptencoding utf-8
if !dko#IsPlugged('fzf.vim') | finish | endif

let g:fzf_command_prefix = 'FZF'

let g:fzf_layout = { 'down': '10' }

" [Buffers] Jump to the existing window if possible
let g:fzf_buffers_jump = 1

execute dko#MapAll({ 'key': '<F3>', 'command': 'FZFMRU' })
execute dko#MapAll({ 'key': '<F4>', 'command': 'FZFFiles' })
execute dko#MapAll({ 'key': '<F5>', 'command': 'FZFAg' })
execute dko#MapAll({ 'key': '<F8>', 'command': 'FZFColors' })
execute dko#MapAll({ 'key': '<F9>', 'command': 'FZFVim' })

" ============================================================================
" My custom sources
" ============================================================================
"
" Notes:
" - Use fzf#wrap() instead of 'sink' option to get the <C-T/V/X> keybindings
"   when the source is to open files
"

" ansi colors even though I'm not using any right now...
" cycle through list
" multi select with <Tab>
let s:options = '--ansi --cycle --multi'

" ----------------------------------------------------------------------------
" My vim runtime
" ----------------------------------------------------------------------------

" @return {List} my files in my vim runtime
function! s:GetFzfVimSource() abort
  " Want these recomputed every time in case files are added/removed
  let l:runtime_dirs_files = globpath(g:dko#vim_dir, '{' . join([
        \   'after',
        \   'autoload',
        \   'ftplugin',
        \   'plugin',
        \   'snippets',
        \   'syntax',
        \ ], ',') . '}/**/*.vim', 0, 1)
  let l:runtime_files = globpath(g:dko#vim_dir, '*.vim', 0, 1)
  let l:rcfiles = globpath(g:dko#vim_dir, '*vimrc', 0, 1)
  return dko#ShortPaths( l:runtime_dirs_files + l:runtime_files + l:rcfiles )
endfunction

command! FZFVim
      \ call fzf#run(fzf#wrap('Vim', {
      \   'source':   s:GetFzfVimSource(),
      \   'options':  s:options . ' --prompt="Vim> "',
      \   'down':     10,
      \ }))

" ----------------------------------------------------------------------------
" Whitelisted MRU/Buffer combined
" Regular MRU doesn't blacklist files
" ----------------------------------------------------------------------------

" @return {List} recently used filenames and buffers
function! s:GetFzfMruSource() abort
  return uniq(dko#GetMru() + dko#GetBuffers())
endfunction

command! FZFMRU
      \ call fzf#run(fzf#wrap('MRU', {
      \   'source':  s:GetFzfMruSource(),
      \   'options': s:options . ' --no-sort --prompt="MRU> "',
      \   'down':    10,
      \ }))
