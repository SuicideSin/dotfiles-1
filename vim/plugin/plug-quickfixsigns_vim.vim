" plugin/plug-quickfixsigns_vim.vim

if !dko#IsPlugged('quickfixsigns_vim') | finish | endif

let g:quickfixsigns_balloon = 0
let g:quickfixsigns_classes = [ 'marks', 'vcsdiff', 'breakpoints' ]

" Leave neomake signs alone
if dko#IsPlugged('neomake')
  let g:quickfixsigns_protect_sign_rx = '^neomake_'
endif
