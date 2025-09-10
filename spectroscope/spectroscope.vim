let s:config_path = split(&runtimepath, ',')[0]
let s:log_file = s:config_path . "/log_char.txt"
function! OpenSpecialListBuffer(list, action_map, filetype, vertical, ...)
    let l:wrap = (a:0 >= 1 ? a:1 : 0)  " default = 0 (nowrap)
    if a:vertical
        vertical enew
    else
        enew
    endif
    let l:new_buf = bufnr('%')
    call setbufvar(l:new_buf, '&buftype', 'nofile')
    call setbufvar(l:new_buf, '&bufhidden', 'wipe')
    call setbufvar(l:new_buf, '&swapfile', 0)
    call setbufvar(l:new_buf, '&modifiable', 1)
    call setbufvar(l:new_buf, '&filetype', a:filetype)
    call setbufvar(l:new_buf, '&buflisted', 0)
    call setbufvar(l:new_buf, '&wrap', l:wrap)

    " call setline(1, a:list)
    call setbufline(l:new_buf, 1, a:list)
    call setbufvar(l:new_buf, '&modifiable', 0)

    for [key, func] in items(a:action_map)
        execute 'nnoremap <buffer> ' . key . ' :call ' . func . '(getline("."))<CR>'
    endfor
endfunction


function! s:update_input(input, char)
    if type(a:char) == type(0)
        let c = nr2char(a:char)
    elseif type(a:char) == type('')
        let c = copy(a:char)
    else
        echoerr "invalid type of char: " . string(type(a:char))
        return ""
    endif
    let input = copy(a:input)
    if c ==# "\<BS>" || c ==# "\<Del>" || c ==# "\<C-h>"
        if strlen(input) > 0
            let input = input[:-2]
            return input
        endif
    endif
    let input .= c
    return input
endfunction


function! OpenSpecialListBufferPicker(list, direction_binds, filetype, vertical, ...)
    let l:prev_buf = bufnr('%')
    let l:prev_win = winnr()
    let l:wrap = (a:0 >= 1 ? a:1 : 0)  " default = 0 (nowrap)
    if a:vertical
        vertical enew
    else
        enew
    endif
    let l:new_buf = bufnr('%')

    call setbufvar(l:new_buf, '&buftype', 'nofile')
    call setbufvar(l:new_buf, '&bufhidden', 'wipe')
    call setbufvar(l:new_buf, '&swapfile', 0)
    call setbufvar(l:new_buf, '&modifiable', 1)
    call setbufvar(l:new_buf, '&filetype', a:filetype)
    call setbufvar(l:new_buf, '&buflisted', 0)
    call setbufvar(l:new_buf, '&cursorline', 1)
    highlight CursorLine ctermbg=LightGrey guibg=#555555
    call setbufvar(l:new_buf, '&wrap', l:wrap)

    call setbufline(l:new_buf, 1, a:list)
    call setbufvar(l:new_buf, '&modifiable', 0)

    " for [key, func] in items(a:action_map)
    "     " execute 'silent! nunmap <buffer> ' . key
    "     execute 'nunmap <buffer> ' . key
    "     execute 'nnoremap <buffer> ' . key . ' :call ' . func . '(getline("."))'
    " endfor
    let input = ''
    let match_id = -1
    echo input
    redraw
    let collected_mapping = ''
    let entering = 0
    while 1
        
        let char = getchar()
        " if type(char) == type(0) && char == 0 
        "     continue
        " endif
        " call writefile([string(char) . "==" . nr2char(char) ], s:log_file, 'a')
        " continue

        let l:is_empty = type(char) == type(0) && char == 0 
        if l:is_empty
            continue
        endif
        let l:ALT_KEY = 128
        if char == char2nr('j') + l:ALT_KEY 
            normal! j 
            redraw
            continue
        endif

        if char == char2nr('k') + l:ALT_KEY 
            normal! k 
            redraw
            continue
        endif
        if char == char2nr("\<CR>")
            let entering = 1
            break
        endif
        if char == char2nr("\<Esc>")
            break  
        endif

        let input = s:update_input(input, char)

        if input ==# ''
            let filtered_list = copy(a:list)
        else
            let filtered_list = filter(copy(a:list), 'v:val =~# input')
            call sort(filtered_list, {a, b -> len(a) - stridx(a, input) - (len(b) - stridx(b, input))})
        endif

        call setbufvar(l:new_buf, '&modifiable', 1)
        call deletebufline(l:new_buf, 1, '$')
        call setbufline(l:new_buf, 1, filtered_list)
        call setbufvar(l:new_buf, '&modifiable', 0)
        if match_id != -1
            call matchdelete(match_id)
            let match_id = -1
        endif
        if input != ''
            let pattern = '\V' . escape(input, '\')
            let match_id = matchadd('SpecialKey', pattern)
        endif
        redraw
        echo input
    endwhile
    if entering == 1
        while 1
            echo "Direction:"
            let direction = getchar()
            if direction == char2nr("\<Esc>")
                break
            endif


            let char_direction = nr2char(direction)

            if direction == char2nr("\<CR>")
                let char_direction = ''
            endif

            if has_key(a:direction_binds, char_direction)

                execute 'call ' . a:direction_binds[char_direction] . '(getline("."))'
                break
            endif
            echo "invalid: " . nr2char(direction)
        endwhile
    endif

    let winlist = win_findbuf(l:new_buf)
    for winnr in winlist
        if winnr == l:prev_win
            call win_execute(winnr, 'buffer ' . l:prev_buf)
        else

        endif

    endfor

endfunction


function! s:do_filter(input, list, popup_id, max_lines)
    let input = a:input
    let l:popup_id = a:popup_id
    let l:MAX_LINES = a:max_lines
    
    if input ==# ''
        let filtered_list = copy(a:list)
    else
        let filtered_list = filter(copy(a:list), 'v:val =~# input')
        call sort(filtered_list, {a, b -> len(b) - stridx(b, input) - (len(a) - stridx(a, input))})
    endif


    if len(l:filtered_list) < l:MAX_LINES
        let l:popup_lines = repeat([''], l:MAX_LINES - len(l:filtered_list)) + l:filtered_list
    elseif len(l:filtered_list) > l:MAX_LINES
        let l:popup_lines = l:filtered_list[len(l:filtered_list) - l:MAX_LINES :]
    else
        let l:popup_lines = copy(l:filtered_list)
    endif
    call popup_settext(l:popup_id, l:popup_lines)
endfunction

function! OpenSpecialListBufferPickerFloat(list, direction_binds, filetype)
    let l:MAX_LINES = 10
    let filtered_list = copy(a:list)

    if len(l:filtered_list) < l:MAX_LINES
        let l:popup_lines = repeat([''], l:MAX_LINES - len(l:filtered_list)) + l:filtered_list
    elseif len(l:filtered_list) > l:MAX_LINES
        let l:popup_lines = l:filtered_list[len(l:filtered_list) - l:MAX_LINES :]
    else
        let l:popup_lines = copy(l:filtered_list)
    endif

    let l:width = &columns
    let l:height = &lines

    let l:popup_width = width - 50
    let l:popup_height = len(l:popup_lines)

    let l:row = (l:height - l:popup_height) / 2
    let l:col = (l:width - l:popup_width) / 2

    let l:popup_id = popup_create(
      \ l:popup_lines,
      \ {
      \   'line': l:row,
      \   'col': l:col,
      \   'minwidth': l:popup_width,
      \   'minheight': l:popup_height,
        \ 'border_chars': ['-', '|', '-', '|', '+','+','+','+'],
        \ 'border': [1, 1, 1, 1],
      \   'padding': [0,1,0,1],
      \   'pos': 'topleft',
      \ })
        let l:popup_bottom = l:row + l:popup_height + 2

    let l:popup2_lines = ['']

    let l:popup2_id = popup_create(
          \ [],
          \ {
          \   'line': l:popup_bottom,
          \   'col': l:col,  
          \   'minwidth': l:popup_width,
          \   'padding': [0,1,0,1],
          \   'pos': 'topleft',
            \ 'border': [1, 1, 1, 1 ],
            \ 'border_chars': ['-', '|', '-', '|', '+','+','+','+']
          \ })
    let l:current_index_from_bottom = 0

    let input = ''
    let match_id = -1
    redraw

    let collected_mapping = ''
    let entering = 0

    " let l:linehl = [ 'MyPopupLine' ] + repeat([''], len(l:popup_lines) - 1)

    " highlight MyPopupLine ctermbg=LightGrey guibg=#555555
    " call popup_setoptions(l:popup_id, {'linehl': l:linehl})
    " redraw
    while 1
        let char = getchar()
        let l:is_empty = type(char) == type(0) && char == 0 
        if l:is_empty
            continue
        endif
        let l:ALT_KEY = 128
        if char == char2nr('j') + l:ALT_KEY 
            if l:current_index_from_bottom > 0
                let l:current_index_from_bottom -= 1

                " let l:highlighted = map(copy(l:popup_lines), {idx, val -> idx == l:current_index_from_bottom ? 'MyPopupLine' : ''})
                " call popup_setoptions(l:popup_id, {'linehl': l:highlighted})
                redraw
            endif
            continue
        endif

        if char == char2nr('k') + l:ALT_KEY 
            if l:current_index_from_bottom < len(l:popup_lines) - 1
                let l:current_index_from_bottom += 1
                " let l:highlighted = map(copy(l:popup_lines), {idx, val -> idx == l:current_index_from_bottom ? 'MyPopupLine' : ''})
                " call popup_setoptions(l:popup_id, {'linehl': l:highlighted})
                redraw
            endif
            continue
        endif
        if char == char2nr("\<CR>")
            let entering = 1
            break
        endif
        if char == char2nr("\<Esc>")
            break  
        endif

        let input = s:update_input(input, char)
        " call popup_settext(l:popup2_id, input)
        call popup_setoptions(l:popup2_id, {'title': input})
        " echo input
        if exists('s:filter_timer')
            call timer_stop(s:filter_timer)
        endif

        let s:filter_timer = timer_start(100, {-> s:do_filter(input, a:list, l:popup_id, l:MAX_LINES)})
        redraw
    endwhile

    if entering == 1
        while 1
            echo "Direction:"
            let direction = getchar()
            if direction == char2nr("\<Esc>")
                break
            endif


            let char_direction = nr2char(direction)

            if direction == char2nr("\<CR>")
                let char_direction = ''
            endif

            if has_key(a:direction_binds, char_direction)

                execute 'call ' . a:direction_binds[char_direction] . '("' . l:popup_lines[l:current_index_from_bottom] . '")'
                break
            endif
            echo "invalid: " . nr2char(direction)
        endwhile
    endif


endfunction
