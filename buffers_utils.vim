function! OpenBufferInDirection(bufnr, direction)
    call OpenBufferInDirectionAt(a:bufnr, a:direction, 0, 0)
endfunction

function! OpenBufferAt(bufnr, line, ...)
    let l:col = a:0 ? a:1 : 1
    call OpenBufferInDirectionAt(a:bufnr, '', a:line, l:col)
endfunction

function! OpenBufferVSplitAt(bufnr, line, ...)
    let l:col = a:0 ? a:1 : 1
    call OpenBufferInDirectionAt(a:bufnr, 'v', a:line, l:col)
endfunction

function! OpenBufferInDirectionAt(bufnr, direction, line, col)
    if !bufexists(a:bufnr)
        echo "Buffer does not exist: " . a:bufnr
        return
    endif

    if !bufloaded(a:bufnr)
        execute 'b' a:bufnr
    endif

    if !empty(a:direction)
        if a:direction ==# 'v'
            execute 'vertical sbuffer ' . a:bufnr
        else
            execute 'wincmd ' . a:direction
            execute 'buffer ' . a:bufnr
        endif
    else
        execute 'buffer ' . a:bufnr
    endif

    if a:line != 0 || a:col != 0
        call cursor(a:line, a:col)
    endif
endfunction

function! OpenBufferGeneric(bufnr, ...)
    if !bufexists(a:bufnr)
        echo "Buffer does not exist: " . a:bufnr
        return
    endif

    let l:direction = get(a:000, 0, '')
    let l:line = get(a:000, 1, 1)
    let l:col = get(a:000, 2, 1)

    if l:direction ==# 'v'
        execute 'vertical sbuffer ' . a:bufnr
    else
        if l:direction =~? '^[hjkl]$'
            execute 'wincmd ' . l:direction
        endif
        execute 'buffer ' . a:bufnr
    endif

    if l:line > 1 || l:col > 1
        call cursor(l:line, l:col)
    endif
endfunction
