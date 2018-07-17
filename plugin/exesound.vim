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
let s:se_vol = 700


"----------------------------------------------------------------------
" initialize
"----------------------------------------------------------------------
function! s:exesound_init(enable)
	if a:enable == 0
    call exesound#stop_bgm_in_theme()
		call exesound#play_se_in_theme('ed_se.wav', s:se_vol, -1)
		augroup ExesoundEvents
			au!
		augroup END
	else
		if exesound#init() != 1
			call exesound#errmsg('ERROR: exesound init failed')
			return
		endif
    if g:exesound_auto_nt_open == 1
      if g:NERDTree.IsOpen()
        NERDTreeToggle
	      let s:did_move_in_nt = 0
        syntax off
        redraw
      endif
    endif
    " 戦闘開始se, bgm再生
    call exesound#stop_bgm_in_theme()
		call exesound#play_se_in_theme('op_se.wav', s:se_vol, -1)
    sleep 2500m " TODO: ここのsleep秒数を設定可能にしてブロックされたくない場合に配慮
    call exesound#start_bgm_in_theme('bgm.wav', 0, -1)

    if exists('#TextChangedP') || exists('##TextChangedP')
			augroup ExesoundEvents
				au! 
				au InsertEnter * call s:event_insert_enter()
				au TextChangedI * call s:event_text_changed()
				au TextChangedP * call s:event_text_changed()
				au CursorMoved * call s:event_cursor_moved()
				au BufEnter * call s:event_buf_enter()
			augroup END
		else
			augroup ExesoundEvents
				au! 
				au InsertEnter * call s:event_insert_enter()
				au TextChangedI * call s:event_text_changed()
				au CursorMoved * call s:event_cursor_moved()
				au BufEnter * call s:event_buf_enter()
			augroup END
		endif

    if g:exesound_auto_nt_open == 1
      syntax on
      redraw
      sleep 600m
      NERDTreeToggle
    endif
	endif
endfunc

function! s:event_vim_enter()
	if get(g:, 'exesound_enable', 0) != 0
		call s:exesound_init(1)
	endif
endfunc

function! s:event_insert_enter()
	let s:last_row = line('.')
	let s:last_col = col('.')
endfunc

function! s:event_text_changed()
	let cur_row = line('.')
	let cur_col = col('.')
  if !g:NERDTree.IsOpen()
	  if cur_row == s:last_row && cur_col != s:last_col
	  	call exesound#play_se_in_theme('keyany.wav', s:se_vol, -1)
	  elseif cur_row > s:last_row && cur_col <= s:last_col
	  	call exesound#play_se_in_theme("keyenter.wav", s:se_vol, -1)
	  elseif cur_row < s:last_row
	  	call exesound#play_se_in_theme("keyany.wav", s:se_vol, -1)
	  endif
  endif
	let s:last_row = cur_row
	let s:last_col = cur_col
endfunc

function! s:event_cursor_moved()
	if !exists('s:did_move_in_nt')
	  let s:did_move_in_nt = 0
	endif

  if g:NERDTree.IsOpen()
    if g:NERDTree.ExistsForBuf()
      if s:did_move_in_nt == 1
        call exesound#play_se_in_theme("nt_select_se.wav", s:se_vol, -1)
      endif
      let s:did_move_in_nt = 1
    else
      let s:did_move_in_nt = 0
    endif
  else
    " play key any se
    let s:did_move_in_nt = 0
  endif

endfunc

function! s:event_buf_enter()
  if !exists('g:exesound_auto_focus_on_nt')
    " let g:exesound_auto_focus_on_nt = 0
    let g:exesound_auto_focus_on_nt = 1 " debug setting
  endif
  if !exists('s:was_nt_opened')
    let s:was_nt_opened = 0
  endif

  if g:NERDTree.IsOpen()
    if !g:NERDTree.ExistsForBuf()
      call exesound#play_se_in_theme("nt_choose_se.wav", s:se_vol, -1)
      if g:exesound_auto_focus_on_nt
        NERDTreeFocus
      endif
    else
      call exesound#play_se_in_theme("nt_open_se.wav", s:se_vol, -1)
      " play open custom se
    endif
    let s:was_nt_opened = 1
  else
    if s:was_nt_opened
      call exesound#play_se_in_theme("nt_close_se.wav", s:se_vol+300, -1)
    endif
    let s:was_nt_opened = 0
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
