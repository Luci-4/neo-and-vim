let s:config_path = split(&runtimepath, ',')[0]

function! OpenSpecialListBuffer(list, action_map, filetype, vertical, wrap, ...) abort
    let l:format_callback = get(a:000, 0, '')
    if a:vertical
        vsplit
        enew
    else
        enew
    endif
    let l:new_buf = bufnr('%')
    call setbufvar(l:new_buf, '&buftype', 'nofile')
    call setbufvar(l:new_buf, '&bufhidden', 'wipe')
    call setbufvar(l:new_buf, '&swapfile', 0)
    call setbufvar(l:new_buf, '&modifiable', 1)
    call setbufvar(l:new_buf, '&filetype', a:filetype)
    call setbufvar(l:new_buf, '&buflisted', 1)

    call setbufvar(l:new_buf, '&cursorline', 1)
    highlight CursorLine ctermbg=LightGrey guibg=#555555 gui=NONE cterm=NONE
    call setbufvar(l:new_buf, '&wrap', a:wrap)

    " call setline(1, a:list)
    if !empty(l:format_callback)
        let l:formatted_list = map(copy(a:list), l:format_callback . '(v:val)')
        call setbufvar(l:new_buf, 'raw_list', a:list)
        call setbufvar(l:new_buf, 'special_list', l:formatted_list)
        call setbufline(l:new_buf, 1, l:formatted_list)
        for [key, func] in items(a:action_map)
            execute 'nnoremap <buffer> ' . key . ' :call ' . func . '(getbufvar(' . l:new_buf . ', "raw_list")[line(".")-1])<CR>'
        endfor
    else
        call setbufline(l:new_buf, 1, a:list)
        for [key, func] in items(a:action_map)
            execute 'nnoremap <buffer> ' . key . ' :call ' . func . '(getline("."))<CR>'
        endfor
    endif
    call setbufvar(l:new_buf, '&modifiable', 0)

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
        if !empty(input)
            let input = input[:-2]
        endif
        return input
    endif
    let input .= c
    return input
endfunction


if !exists('g:last_opened_picker')
    let g:last_opened_picker= {}
endif
if !exists('g:special_list_buffers')
    let g:special_list_buffers = {}
endif
function! SetupSpecialListBufferPicker(filetype)
    if !has_key(g:special_list_buffers, a:filetype) || !bufexists(g:special_list_buffers[a:filetype])
        let l:buf = bufadd('')  " empty name = unnamed buffer
        call setbufvar(l:buf, '&buftype', 'nofile')
        call setbufvar(l:buf, '&bufhidden', 'hide')
        call setbufvar(l:buf, '&swapfile', 0)
        call setbufvar(l:buf, '&modifiable', 1)
        call setbufvar(l:buf, '&filetype', a:filetype)
        call setbufvar(l:buf, '&buflisted', 1)
        call setbufvar(l:buf, '&cursorline', 1)
        highlight CursorLine ctermbg=LightGrey guibg=#555555 gui=NONE cterm=NONE
        call setbufvar(l:buf, '&modifiable', 0)
        let g:special_list_buffers[a:filetype] = l:buf
    endif
endfunction

function! s:update_results(input, filtered_list, bufnr)
    let input = a:input
    let filtered_list = a:filtered_list
    let l:new_buf = a:bufnr
    let match_id = getbufvar(l:new_buf, 'match_id')

    call setbufvar(l:new_buf, '&modifiable', 1)
    call deletebufline(l:new_buf, 1, '$')
    call setbufline(l:new_buf, 1, filtered_list)
    call setbufvar(l:new_buf, '&modifiable', 0)
    if match_id != -1
        call matchdelete(match_id)
        call setbufvar(l:new_buf, 'match_id', -1)
    endif
    if !empty(input)
        let pattern = '\v(:\d+:)?\d+:' . '\zs' . escape(input, '\')
        call setbufvar(l:new_buf, 'match_id', matchadd('Search', pattern))
    endif
    redraw
endfunction

function! RunPickerWhile(buf, input, list, filter_callback)

    call clearmatches()
    let l:new_buf = a:buf 
    call setbufvar(l:new_buf, 'match_id', -1)
    let input = a:input
    if empty(input)
        let input = getbufvar(l:new_buf, 'input')
    endif
    let list = a:list
    if empty(list)
        let list  = getbufvar(l:new_buf, 'list')
    endif

    let entering = 0
    if !empty(input)
        let filtered_list = call(a:filter_callback, [list, input]) 
        call s:update_results(input, filtered_list, l:new_buf)
    endif

    echo input
    while 1
        let char = getchar()
        let l:is_empty = type(char) == type(0) && char == 0 
        if l:is_empty
            continue
        endif
        if has('nvim') 
            if char ==# "\<M-j>"
                normal! j
                redraw
                continue
            elseif char ==# "\<M-k>"
                normal! k
                redraw
                continue
            endif
        else
            if IsOnLinux()
                let l:ALT_KEY_LINUX = 27
                if char == l:ALT_KEY_LINUX
                    let next = getchar()        
                    if next == char2nr('j')
                        normal! j 
                        redraw
                    endif
                    if next == char2nr('k')
                        normal! k 
                        redraw
                    endif
                    continue
                endif
            else
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
            endif
        endif
        if char == char2nr("\<CR>")
            let entering = 1
            break
        endif
        if char == char2nr("\<") || char == char2nr("\<Esc>")
            let entering = 0
            break
        endif

        let input = s:update_input(input, char)

        if empty(input)
            let filtered_list = copy(list)
        else
            let filtered_list = call(a:filter_callback, [list, input]) 
        endif
        call s:update_results(input, filtered_list, l:new_buf)
        echo input
    endwhile
    call setbufvar(l:new_buf, 'input', input)

    let direction_binds = getbufvar(l:new_buf, 'direction_binds')
    if !empty(input)
        let filetype = getbufvar(l:new_buf, '&filetype')
        let g:last_opened_picker[filetype] = {}
        let g:last_opened_picker[filetype]['input'] = input
        let g:last_opened_picker[filetype]['list'] = filtered_list
        let g:last_opened_picker[filetype]['cursor_line'] = line('.')
    endif

    if entering == 0
        return filtered_list
    endif
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

        if has_key(direction_binds, char_direction)
            execute 'call ' . direction_binds[char_direction] . '(getline("."))'
            break
        endif
        echo "invalid: " . nr2char(direction)
    endwhile
endfunction



function! OpenSpecialListBufferPicker(list, input, direction_binds, filter_callback, filetype, vertical, reopen, wrap, solidified_action_map, ...) abort
    let l:format_callback = get(a:000, 0, '')

    if has_key(g:special_list_buffers, a:filetype) || !bufexists(g:special_list_buffers[a:filetype])
        call SetupSpecialListBufferPicker(a:filetype)
    endif

    let l:new_buf = g:special_list_buffers[a:filetype]

    call setbufvar(l:new_buf, '&filetype', a:filetype)
    let l:win = bufwinnr(l:new_buf) 
    let l:buffer_not_opened_in_window = bufwinnr(l:new_buf) == -1

    let input = a:reopen == 1 ? get(get(g:last_opened_picker, a:filetype, {}), "input", '') : a:input
    if a:reopen == 1
      let lnum = get(get(g:last_opened_picker, a:filetype, {}), "cursor_line", 1)
      call cursor(lnum, 1)
    endif
    if l:buffer_not_opened_in_window
        if a:reopen == 0
            call ClearSpectroscopePickerCache(a:filetype)
        endif

        call setbufvar(l:new_buf, "input", input)
        execute 'vertical sbuffer' l:new_buf
        call setbufvar(l:new_buf, '&modifiable', 1)
        call deletebufline(l:new_buf, 1, '$')
        call setbufline(l:new_buf, 1, a:list)

        for [key, func] in items(a:solidified_action_map)
            execute 'nnoremap <buffer> ' . key . ' :call ' . func . '(getline("."))<CR>'
        endfor
        call setbufvar(l:new_buf, '&wrap', a:wrap)
        call setbufvar(l:new_buf, '&cursorline', 1)
        call setbufvar(l:new_buf, '&modifiable', 0)
        call setbufvar(l:new_buf, 'list', a:list)
        call setbufvar(l:new_buf, '&filetype', a:filetype)
        call setbufvar(l:new_buf, '&buflisted', 1)
        call setbufvar(l:new_buf, 'direction_binds', a:direction_binds)
    else
        execute l:win . 'wincmd w'
    endif
    redraw
    let filtered_list = RunPickerWhile(l:new_buf, input, a:list, a:filter_callback)
    if empty(filtered_list)
        return
    endif
    call OpenSpecialListBuffer(filtered_list, a:solidified_action_map, a:filetype, 0, a:wrap)
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


