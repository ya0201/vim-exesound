"======================================================================
"
" exesound.vim - 
"
" Created by skywind on 2018/05/01
" Last Modified: 2018/05/01 18:21:05
"
"======================================================================


"----------------------------------------------------------------------
" internal state
"----------------------------------------------------------------------
let s:last_row = -1
let s:last_col = -1


"----------------------------------------------------------------------
" initialize
"----------------------------------------------------------------------
function! s:exesound_init(enable)
	if a:enable == 0
		augroup ExesoundEvents
			au!
		augroup END
	else
		if exesound#init() != 1
			call exesound#errmsg('ERROR: exesound init failed')
			return
		endif
    " 戦闘開始se, bgm再生
    call exesound#start_bgm_in_theme('bgm.wav', 450, -1)
		if exists('#TextChangedP') || exists('##TextChangedP')
			augroup ExesoundEvents
				au! 
				au InsertEnter * call s:event_insert_enter()
				au TextChangedI * call s:event_text_changed()
				au TextChangedP * call s:event_text_changed()
			augroup END
		else
			augroup ExesoundEvents
				au! 
				au InsertEnter * call s:event_insert_enter()
				au TextChangedI * call s:event_text_changed()
			augroup END
		endif
	endif
endfunc

function! s:event_insert_enter()
	let s:last_row = line('.')
	let s:last_col = col('.')
endfunc

function! s:event_text_changed()
	let cur_row = line('.')
	let cur_col = col('.')
	if cur_row == s:last_row && cur_col != s:last_col
		call exesound#play_se_in_theme('keyany.wav', 450, -1)
	elseif cur_row > s:last_row && cur_col <= s:last_col
		call exesound#play_se_in_theme("keyenter.wav", 450, -1)
	elseif cur_row < s:last_row
		call exesound#play_se_in_theme("keyany.wav", 450, -1)
	endif
	let s:last_row = cur_row
	let s:last_col = cur_col
endfunc

function! s:event_vim_enter()
	if get(g:, 'exesound_enable', 0) != 0
		call s:exesound_init(1)
	endif
endfunc


"----------------------------------------------------------------------
" VimEnter
"----------------------------------------------------------------------
augroup ExesoundEnterEvent
	au!
	au VimEnter * call s:event_vim_enter()
augroup END


"----------------------------------------------------------------------
" commands
"----------------------------------------------------------------------
command! -nargs=0 ExesoundEnable call s:exesound_init(1)
command! -nargs=0 ExesoundDisable call s:exesound_init(0)

