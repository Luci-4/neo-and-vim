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

function! ToggleSingleTerminal()
    if tabpagenr('$') < 2
        tabnew
    else
        if tabpagenr() != 2
            execute "tabnext 2"
        else
            execute "tabnext 1"
            return
        endif

    endif


    let term_buf_name = "__MY_TERMINAL__"
    let term_buf = -1

    for buf in range(1, bufnr('$'))
        if bufexists(buf) && bufname(buf) ==# term_buf_name
            let term_buf = buf
            break
        endif
    endfor

    if term_buf != -1
        let displayed = 0
        for win in range(1, winnr('$'))
            if winbufnr(win) == term_buf
                let displayed = 1
                break
            endif
        endfor

        if !displayed
            execute "buffer " . term_buf
        endif
        return 
    endif

    execute "terminal"
    execute "file " . term_buf_name
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
