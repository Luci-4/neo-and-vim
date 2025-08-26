function! OpenSpecialListBuffer(list, action_map, filetype, vertical, ...)
    let l:wrap = (a:0 >= 1 ? a:1 : 0)  " default = 0 (nowrap)
    if a:vertical
        vertical enew
    else
        enew
    endif

    setlocal buftype=nofile
    setlocal bufhidden=wipe
    setlocal noswapfile
    setlocal modifiable
    execute 'setlocal filetype=' . a:filetype
    setlocal nobuflisted
    if l:wrap
        setlocal wrap
    else
        setlocal nowrap
    endif

    call setline(1, a:list)
    setlocal nomodifiable
    for [key, func] in items(a:action_map)
        execute 'nnoremap <buffer> ' . key . ' :call ' . func . '(getline("."))<CR>'
    endfor
endfunction
