" plugin/plug-vim-indent-guides.vim
if !dko#IsPlugged('vim-indent-guides') | finish | endif
let s:cpo_save = &cpoptions
set cpoptions&vim

let g:indent_guides_color_change_percent = 3

" The autocmd hooks are run after plugins loaded so okay to reference them in
" this file even though it is sourced before the functions are defined.
augroup dkoindentguides
  autocmd!
  autocmd BufEnter  *.hbs,*.html,*.mustache   IndentGuidesEnable
  autocmd BufLeave  *.hbs,*.html,*.mustache   IndentGuidesDisable
augroup END

let s:cpo_save = &cpoptions
set cpoptions&vim
