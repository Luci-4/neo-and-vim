let s:config_path = split(&runtimepath, ',')[0]
execute 'source' s:config_path . '/settings.vim'
execute 'source' s:config_path . '/remaps.vim'
execute 'source' s:config_path . '/markdown.vim'

function! SetStatusLine()
    set statusline=%f\ %y\ %{g:breadcrumbs}\ %=Ln:%l\ Col:%c
endfunction

autocmd VimEnter * if get(g:, 'breadcrumbs', '') !=# '' | call SetStatusLine() | endif
autocmd VimEnter * call SetupSpecialListBufferPicker()



" function! RunTestPopup()
"     echom "running test"
" let l:content = ['Hello, this is a centered popup!', 'Second line']

" " Get the current screen size
" let l:width = &columns
" let l:height = &lines

" " Calculate popup size
" let l:popup_width = 40
" let l:popup_height = len(l:content)

" let l:row = (l:height - l:popup_height) / 2
" let l:col = (l:width - l:popup_width) / 2

" " Create the popup
" let l:popup_id = popup_create(
"       \ l:content,
"       \ {
    "       \   'line': l:row,
    "       \   'col': l:col,
    "       \   'minwidth': l:popup_width,
    "       \   'minheight': l:popup_height,
    "       \   'border': [],
    "       \   'padding': [0,1,0,1],
    "       \   'pos': 'topleft'
    "       \ })
    " " echom l:popup_stuff
    " call timer_start(2000, { -> popup_settext(l:popup_id, ['Updated!', 'New line']) })
    " endfunction
    " call RunTestPopup()
