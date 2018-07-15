"======================================================================
"
" keysound.vim - 
"
" Created by skywind on 2018/05/01
" Last Modified: 2018/05/01 18:20:28
"
"======================================================================


"----------------------------------------------------------------------
" global settings
"----------------------------------------------------------------------
if !exists('g:exesound_py_version')
	let g:exesound_py_version = 0
endif

if !exists('g:exesound_theme')
	let g:exesound_theme = 'exe'
endif

" if !exists('g:exesound_replace')
"   let g:exesound_replace = 1
" endif

if !exists('g:exesound_volume')
	let g:exesound_volume = 450
endif


"----------------------------------------------------------------------
" tools
"----------------------------------------------------------------------
function! exesound#errmsg(msg)
	redraw | echo '' | redraw
	echohl ErrorMsg
	echom a:msg
	echohl NONE
endfunc


"----------------------------------------------------------------------
" python init 
"----------------------------------------------------------------------
let s:scripthome = expand('<sfile>:p:h')
let s:py_cmd = ''
let s:py_eval = ''
let s:py_version = 0

if g:exesound_py_version == 0
	if has('python')
		let s:py_cmd = 'py'
		let s:py_eval = 'pyeval'
		let s:py_version = 2
	elseif has('python3')
		let s:py_cmd = 'py3'
		let s:py_eval = 'py3eval'
		let s:py_version = 3
	else
		call exesound#errmsg('vim does not support +python/+python3 feature')
	endif
elseif g:exesound_py_version == 2
	if has('python')
		let s:py_cmd = 'py'
		let s:py_eval = 'pyeval'
		let s:py_version = 2
	else
		call exesound#errmsg('vim does not support +python feature')
	endif
elseif g:exesound_py_version == 3
	if has('python3')
		let s:py_cmd = 'py3'
		let s:py_eval = 'py3eval'
		let s:py_version = 3
	else
		call exesound#errmsg('vim does not support +python3 feature')
	endif
endif

function! s:python(script)
	exec s:py_cmd a:script
endfunc

function! s:pyeval(script)
	if s:py_version == 2
		return pyeval(a:script)
	else
		return py3eval(a:script)
	endif
endfunc


"----------------------------------------------------------------------
" local init
"----------------------------------------------------------------------
call s:python('import sys')
call s:python('import os')
call s:python('import vim')
call s:python('import random')
call s:python('sys.path.append(vim.eval("s:scripthome"))')

let g:exesound#inited = 0
let s:themes = {}


"----------------------------------------------------------------------
" init import
"----------------------------------------------------------------------
function! s:init()
	if s:py_cmd == ''
		return 0
	endif
	if g:exesound#inited == 0
		call s:python('import exesound')
		let g:exesound#inited = 1
	endif
	return 1
endfunc


"----------------------------------------------------------------------
" play a sound
"----------------------------------------------------------------------
function! exesound#play_se_file(filepath, volume, channel)
  let s:filepath = a:filepath
  let s:volume = a:volume
  let s:channel = a:channel
	call s:init()
	" call s:python('v = int(vim.eval("s:volume")) * 0.001')
	" call s:python('c = int(vim.eval("s:channel"))')
	" call s:python('exesound.play_se(vim.eval("s:filepath"), v, c)')
	call s:python('v = int(vim.eval("s:volume")) * 0.001')
	call s:python('c = int(vim.eval("s:channel"))')
	call s:python('exesound.play_se(vim.eval("s:filepath"), v, c)')
endfunc

function! exesound#start_bgm_file(filepath, volume, channel)
  let s:filepath = a:filepath
  let s:volume = a:volume
  let s:channel = a:channel
	call s:init()
	call s:python('v = int(vim.eval("s:volume")) * 0.001')
	call s:python('c = int(vim.eval("s:channel"))')
	call s:python('exesound.start_bgm(vim.eval("s:filepath"), v, c)')
endfunc


"----------------------------------------------------------------------
" choose_theme 
"----------------------------------------------------------------------
function! s:choose_theme(theme)
	for rtp in split(&rtp, ',')
		let s:path = fnamemodify(rtp, ':p')
		let s:join = 'sounds/' . a:theme
		let s:path = s:pyeval("os.path.join(vim.eval('s:path'), vim.eval('s:join'))")
		let s:path = s:pyeval("os.path.abspath(vim.eval('s:path'))")
		if isdirectory(s:path)
			return s:path
		endif
	endfor
endfunc

function! s:search_file(filename)
	let theme = g:exesound_theme
  if has_key(s:themes, theme)
		let path = s:themes[theme]
	else
		let path = s:choose_theme(theme)
		let s:themes[theme] = path
	endif
	if path == ''
		call exesound#errmsg('ERROR: can not find theme "sounds/'. theme. '" folder in runtimepaths')
		return 
	endif
	let fn = path . '/' . a:filename
	if !filereadable(fn)
		call exesound#errmsg('ERROR: not find "'. a:filename.'" in "'.path.'"')
		return
	endif
  return fn
endfunc

"----------------------------------------------------------------------
" play a sound in given theme
"----------------------------------------------------------------------
function! exesound#play_se_in_theme(filename, volume, channel)
	" let theme = g:exesound_theme
	" let volume = (a:0 > 0)? a:1 : 1000
	" let channel = (a:0 > 1)? a:2 : -1
	" if has_key(s:themes, theme)
	"   let path = s:themes[theme]
	" else
	"   let path = s:choose_theme(theme)
	"   let s:themes[theme] = path
	" endif
	" if path == ''
	"   call exesound#errmsg('ERROR: can not find theme "sounds/'. theme. '" folder in runtimepaths')
	"   return 
	" endif
	" let fn = path . '/' . a:filename
	" if !filereadable(fn)
	"   call exesound#errmsg('ERROR: not find "'. a:filename.'" in "'.path.'"')
	"   return
	" endif
	" call exesound#play_se(fn, volume, channel)
  let fn = s:search_file(a:filename)
	call exesound#play_se_file(fn, a:volume, a:channel)
endfunc

function! exesound#start_bgm_in_theme(filename, volume, channel)
  let fn = s:search_file(a:filename)
	call exesound#start_bgm_file(fn, a:volume, a:channel)
endfunc

function! exesound#stop_bgm_in_theme()
	call s:init()
	call s:python('exesound.stop_bgm()')
endfunc


"----------------------------------------------------------------------
" choose volume 
"----------------------------------------------------------------------
" function! s:random(range)
"   let s:range = a:range
"   return s:pyeval('random.randint(0, int(vim.eval("s:range")))')
" endfunc

function! exesound#init() abort
	if s:init() == 0
		return 0
	endif
	call s:python('exesound.play_se("")')
	return 1
endfunc

" function! exesound#play(key)
"   " let volume = g:exesound_volume - s:random(g:exesound_volume / 5)
"   let volume = g:exesound_volume
"   if a:key == "\n"
"     if g:exesound_replace == 0
"       call s:play_theme_se('keyenter.wav', volume)
"     else
"       call s:play_theme_se('keyenter.wav', volume, 0)
"     endif
"   else
"     if g:exesound_replace == 0
"       call s:play_theme_se('keyany.wav', volume)
"     else
"       call s:play_theme_se('keyany.wav', volume, 1)
"     endif
"   endif
" endfunc
