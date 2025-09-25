function! OpenNewTerminal() abort
    botright split
    execute has('nvim') ? 'terminal' : 'term'
    resize 15
endfunction

function! OpenTerminal(bufnr) abort
    if bufexists(a:bufnr) && getbufvar(a:bufnr, '&buftype') ==# 'terminal'
        execute 'sbuffer' a:bufnr
    else
        echo "No such terminal buffer: " . a:bufnr
    endif
endfunction

function! RunTermCommand(cmd) abort
    botright split
    execute has('nvim') ? 'terminal' : 'term'
    resize 15
    let l:job = b:terminal_job_id
    call chansend(l:job, a:cmd . "\n")
endfunction

function! ToggleLastTerminal() abort
    let l:terminals = filter(range(1, bufnr('$')), 'bufexists(v:val) && getbufvar(v:val, "&buftype") ==# "terminal"')
    if empty(l:terminals)
        echo "No terminal buffer found"
        return
    endif

    let l:last_term = max(l:terminals)

    execute 'sbuffer' l:last_term
endfunction

function! NextTerminal() abort
    let start = bufnr('%')
    let buf = start
    while 1
        let buf = bufnr(buf + 1)
        if buf == -1
            let buf = bufnr(1)
        endif
        if buf == start
            echo "No other terminal buffer"
            return
        endif
        if getbufvar(buf, '&buftype') ==# 'terminal'
            execute 'sbuffer' buf
            return
        endif
    endwhile
endfunction

function! PrevTerminal() abort
    let start = bufnr('%')
    let buf = start
    while 1
        let buf = bufnr(buf - 1)
        if buf == -1
            let buf = bufnr('$')
        endif
        if buf == start
            echo "No other terminal buffer"
            return
        endif
        if getbufvar(buf, '&buftype') ==# 'terminal'
            execute 'sbuffer' buf
            return
        endif
    endwhile
endfunction

function! CloseTerminal(bufnr) abort
    if bufexists(a:bufnr) && getbufvar(a:bufnr, '&buftype') ==# 'terminal'
        execute 'bwipeout' a:bufnr
    else
        echo "Not a terminal buffer: " . a:bufnr
    endif
endfunction
