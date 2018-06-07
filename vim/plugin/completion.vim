" plugin/completion.vim

let s:cpo_save = &cpoptions
set cpoptions&vim

augroup dkocompletion
  autocmd!
augroup END

" ============================================================================
" Filename completion
" ============================================================================

" useful for filename completion relative to current buffer path
if exists('+autochdir')
  autocmd dkocompletion InsertEnter *
        \ let b:save_cwd = getcwd() | set autochdir
  autocmd dkocompletion InsertLeave *
        \ set noautochdir | execute 'cd' fnameescape(b:save_cwd)
endif

" ============================================================================
" Deoplete
" ============================================================================

" ----------------------------------------------------------------------------
" Conditionally disable deoplete
" For JS files, deoplete-ternjs looks for .tern-project from the file dir
" upwards. If editing a file in a directory that doesn't exist (e.g. NetRW or
" creating by doing `e newdir/newfile.js`) disable deoplete until the file is
" written (which will create the directory automatically thanks to vim-easydir)
" ----------------------------------------------------------------------------

function! s:disableDeopleteIfNoDir()
  if !isdirectory(expand('%:h'))
    let b:deoplete_disable_auto_complete = 1
    let b:dko_enable_deoplete_on_save = 1
  endif
endfunction

function! s:enableDeopleteOnWriteDir()
  if get(b:, 'dko_enable_deoplete_on_save', 0) && isdirectory(expand('%:h'))
    let b:deoplete_disable_auto_complete = 0
    let b:dko_enable_deoplete_on_save = 0
  endif
endfunction

autocmd dkocompletion BufNewFile    *.js  call s:disableDeopleteIfNoDir()
autocmd dkocompletion BufWritePost  *.js  call s:enableDeopleteOnWriteDir()

" ----------------------------------------------------------------------------
" Regexes to use completion engine
" See plugins sections too (e.g. phpcomplete and jspc)
" ----------------------------------------------------------------------------

let s:REGEX = {}
let s:REGEX.any_word        = '\h\w*'
let s:REGEX.nonspace        = '[^-. \t]'
let s:REGEX.nonspace_dot    = s:REGEX.nonspace . '\.\w*'
let s:REGEX.member = s:REGEX.nonspace . '->\w*'
let s:REGEX.static = s:REGEX.any_word . '::\w*'

" For jspc.vim
let s:REGEX.keychar   = '\k\zs \+'
let s:REGEX.parameter = s:REGEX.keychar . '\|' . '(' . '\|' . ':'

" Py3 regex notes:
" - \s is a space
let s:PY3REGEX = {}
let s:PY3REGEX.word = '\w+'

" For css and preprocessors
let s:PY3REGEX.starting_word  = '^\s*' . s:PY3REGEX.word
let s:PY3REGEX.css_media      = '^\s*@'
let s:PY3REGEX.css_value      = ': \w*'

" For jspc.vim
" parameter completion for window.addEventListener('___
" single quote escaped as ''
" literal parentheses escaped as \(
let s:PY3REGEX.parameter = '\.\w+\('''

" For phpcomplete.vim
let s:PY3REGEX.member = '->\w*'
let s:PY3REGEX.static = s:PY3REGEX.word . '::\w*'

" ----------------------------------------------------------------------------
" Deoplete -- if any of these match what you're typing, deoplete will collect
" the omnifunc results and put them in the PUM with any other results.
" - Python 3 regex
" ----------------------------------------------------------------------------

" If you set a filetype key, completion will ONLY be triggered for the
" matching regex; so leave unset if possible.
let s:deo_patterns = {}

" Not using deoplete defaults from omni.py because if you hit <TAB> after
" a full rule, e.g. `margin: 1em;<TAB>` it will trigger completion of a new
" rule. These regexes only complete for one rule per line.
let s:deo_patterns.css  = [
      \   s:PY3REGEX.css_media,
      \   s:PY3REGEX.starting_word,
      \   s:PY3REGEX.starting_word . s:PY3REGEX.css_value,
      \   s:PY3REGEX.css_media . '\w*',
      \   s:PY3REGEX.css_media . s:PY3REGEX.css_value,
      \   s:PY3REGEX.css_value . '\s*!',
      \   s:PY3REGEX.css_value . '\s*!',
      \ ]
let s:deo_patterns.less = s:deo_patterns.css
let s:deo_patterns.sass = s:deo_patterns.css
let s:deo_patterns.scss = s:deo_patterns.css

" JS patterns are defined per plugin
let s:deo_patterns.javascript = [
      \   s:PY3REGEX.word,
      \ ]

" https://github.com/Shougo/deoplete.nvim/blob/5fc5ed772de138439322d728b103a7cb225cbf82/doc/deoplete.txt#L300
" let s:deo_patterns.php = [
"       \   s:PY3REGEX.word,
"       \   s:PY3REGEX.member,
"       \   s:PY3REGEX.static,
"       \ ]

" ----------------------------------------------------------------------------
" Regexes to force omnifunc completion
" See plugins sections too (e.g. tern)
" ----------------------------------------------------------------------------

" When defined for a filetype, call the omnifunc directly (feedkeys
" <C-X><C-O>) instead of delegating to completion plugin. See each plugin
" section for settings.
" deoplete dict:    g:deoplete#omni_patterns
" - string vim regex
let s:omni_only = get(g:, 'deoplete#_omni_patterns', {})

" c-type with clang_complete -- not used but correct
" let s:omni_only.c =       '[^.[:digit:] *\t]\%(\.\|->\)\%(\h\w*\)\?',
" let s:omni_only.cpp =     '[^.[:digit:] *\t]\%(\.\|->\)\%(\h\w*\)\?\|\h\w*::\%(\h\w*\)\?',
" let s:omni_only.objc =    '\[\h\w*\s\h\?\|\h\w*\%(\.\|->\)'
" let s:omni_only.objcpp =  '\[\h\w*\s\h\?\|\h\w*\%(\.\|->\)\|\h\w*::\w*'

" ruby with Shougo/neocomplete-rsense -- not used but correct
" https://github.com/Shougo/neocomplete.vim/blob/master/doc/neocomplete.txt#L1605
" let s:omni_only.ruby = '[^. *\t]\.\w*\|\h\w*::'

" python with davidhalter/jedi-vim -- not used but correct
" https://github.com/Shougo/neocomplete.vim/blob/master/doc/neocomplete.txt#L1617
" let s:omni_only.python = '\%([^. \t]\.\|^\s*@\|^\s*from\s.\+import \|^\s*from \|^\s*import \)\w*'

" typescript with Quramy/tsuquyomi -- not used but correct
" let s:omni_only.typescript = '[^. \t]\.\%(\h\w*\)\?'
" let s:omni_only.typescript = '\h\w*\|[^. \t]\.\w*' -- maybe more relaxed

" ----------------------------------------------------------------------------
" Omnifunc for each filetype
" ----------------------------------------------------------------------------

" When triggering a completion within an engine, use these omnifuncs
" deoplete    g:deoplete#omni#functions
" - list of omnifunc function names
let s:omnifuncs = {
      \   'javascript': [ 'javascriptcomplete#CompleteJS' ],
      \   'html':       [ 'htmlcomplete#CompleteTags' ],
      \ }

" ============================================================================
" Helper functions
" ============================================================================

" Include an omnifunc from deoplete aggregation
"
" @param {String} ft
" @param {String} funcname
" @return {String[]} omnifunc list for the ft
function! s:Include(ft, funcname) abort
  return insert(s:omnifuncs[a:ft], a:funcname)
endfunction

" Exclude an omnifunc from deoplete aggregation
"
" @param {String} ft
" @param {String} funcname
" @return {String[]} omnifunc list for the ft
function! s:Exclude(ft, funcname) abort
  let l:index = index(s:omnifuncs[a:ft], a:funcname)
  if l:index >= 0
    return remove(s:omnifuncs[a:ft], l:index)
  endif
  return s:omnifuncs[a:ft]
endfunction

" Trigger deoplete aggregated omnifunc when matching this regex
"
" @param {String} ft
" @param {List} regexps
" @param {List} [a:] a:1 clear?
function! s:Trigger(ft, regexps, ...) abort
  if !empty(a:000)
    let s:deo_patterns[a:ft] = a:regexps
  else
    call extend(s:deo_patterns[a:ft], a:regexps)
  endif
endfunction

" ============================================================================
" Completion Plugin: vim-better-javascript-completion
" ============================================================================

if dko#IsPlugged('vim-better-javascript-completion')
  " insert instead of add, this is preferred completion omnifunc (except tern)
  autocmd dkocompletion FileType javascript setlocal omnifunc=js#CompleteJS
  call s:Include('javascript', 'js#CompleteJS')
endif

" ============================================================================
" Completion Plugin: tern (both nvim and vim versions)
" This overrides all other JS completions when omni_only matches
" ============================================================================

if executable('tern')
  " No reason to use javascriptcomplete when tern is available
  call s:Exclude('javascript', 'javascriptcomplete#CompleteJS')

  " Settings common to deoplete-ternjs (vim var read via python) and
  " tern_for_vim
  " @see https://github.com/carlitux/deoplete-ternjs/blob/5500ae246aa1421a0e578c2c7e1b00d858b2fab2/rplugin/python3/deoplete/sources/ternjs.py#L70-L75
  let g:tern_request_timeout       = 1 " undocumented in tern_for_vim
  let g:tern_show_signature_in_pum = 1

  " --------------------------------------------------------------------------
  " tern_for_vim settings
  " This plugin is used for its refactoring and helper methods, not completion
  " --------------------------------------------------------------------------

  " @TODO deprecated, replace with own plugin
  if dko#IsPlugged('tern_for_vim')
    " Use tabline instead
    let g:tern_show_argument_hints = 'no'

    " Don't set the omnifunc to tern#Complete
    "let g:tern_set_omni_function     = 0

    augroup dkocompletion
      autocmd FileType javascript nnoremap <silent><buffer> gd :<C-U>TernDef<CR>
    augroup END
  endif

  " --------------------------------------------------------------------------
  " deoplete-ternjs settings
  " This plugin adds a custom deoplete source only
  " --------------------------------------------------------------------------

  " Use global tern server instance (same as deoplete-ternjs)
  let g:tern#command   = [ 'tern' ]
  " Don't close tern after 5 minutes, helps speed up deoplete completion if
  " they manage to share the instance
  let g:tern#arguments = [ '--persistent' ]
endif

" ============================================================================
" Completion Plugin: jspc.vim
" (Ignored if s:omni_only.javascript was set by the above tern settings)
" ============================================================================

if dko#IsPlugged('jspc.vim')
  " <C-x><C-u> to manually use jspc in particular
  autocmd dkocompletion FileType javascript setlocal completefunc=jspc#omni

  " jspc.vim calls the original &omnifunc (probably
  " javascriptcomplete#CompleteJS or tern#Complete) if it doesn't match, so we
  " don't need it in the deoplete omnifuncs
  call s:Exclude('javascript', 'javascriptcomplete#CompleteJS')
  call s:Include('javascript', 'jspc#omni')
  " Triggered on quotes in `window.addEventListener('` for example
  call s:Trigger('javascript', [
        \   s:PY3REGEX.parameter,
        \ ])
endif

" ============================================================================
" Completion Plugin: vim-javacomplete2
" ============================================================================

if dko#IsPlugged('vim-javacomplete2')
  let g:JavaComplete_ClosingBrace = 0
  let g:JavaComplete_ShowExternalCommandsOutput = 1
endif

" ============================================================================
" Deoplete
" ============================================================================

if dko#IsPlugged('deoplete.nvim')
  let g:deoplete#enable_ignore_case = 0
  let g:deoplete#enable_smart_case = 1
  let g:deoplete#enable_at_startup  = 1

  " [file] candidates are relative to the buffer path
  let g:deoplete#file#enable_buffer_path = 1

  call deoplete#custom#source('_', 'matchers', [
        \   'matcher_head',
        \   'matcher_length',
        \ ])

  " --------------------------------------------------------------------------
  " Sources for engine based omni-completion (ignored if match s:omni_only)
  " --------------------------------------------------------------------------

  let g:deoplete#omni#functions = s:omnifuncs

  " --------------------------------------------------------------------------
  " Input patterns
  " --------------------------------------------------------------------------

  " Patterns that use &omnifunc directly by synthetic <C-X><C-O>
  call dko#InitDict('g:deoplete#omni_patterns')
  call extend(g:deoplete#omni_patterns, s:omni_only)

  " Patterns that trigger deoplete aggregated PUM
  call dko#InitDict('g:deoplete#omni#input_patterns')
  call extend(g:deoplete#omni#input_patterns, s:deo_patterns)
endif

" ============================================================================

let &cpoptions = s:cpo_save
unlet s:cpo_save
