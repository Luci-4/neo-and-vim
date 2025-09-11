function! OpenFile(file)
    if filereadable(a:file)
        execute 'keepalt edit ' . fnameescape(a:file)
    else
        echo "File does not exist: " . a:file
    endif
endfunction

function! OpenFileVSplitRight(file)
    if filereadable(a:file)
        " Open file in a vertical split on the right (default)
        execute 'vsplit ' . fnameescape(a:file)
    else
        echo "File does not exist: " . a:file
    endif
endfunction

function s:open_file_in_direction(file, direction)
    if empty(a:file)
        echo "No file under cursor"
        return
    endif
    execute "wincmd " . a:direction
    execute "edit " . fnameescape(a:file)
endfunction

function! OpenFileInWindowInDirectionH(file)
    call s:open_file_in_direction(a:file, 'h')
endfunction

function! OpenFileInWindowInDirectionJ(file)
    call s:open_file_in_direction(a:file, 'j')
endfunction

function! OpenFileInWindowInDirectionK(file)
    call s:open_file_in_direction(a:file, 'k')
endfunction

function! OpenFileInWindowInDirectionL(file)
    call s:open_file_in_direction(a:file, 'l')
endfunction

function OpenFileAt(file, line, ...)
    let l:col = a:0 ? a:1 : 1
    if filereadable(a:file)
        execute 'keepalt edit ' . fnameescape(a:file)
    else
        echo "File does not exist: " . a:file
    endif
    call cursor(a:line, l:col)
endfunction


function OpenFileVSplitRightAt(file, line, ...)
    let l:col = a:0 ? a:1 : 1
    if filereadable(a:file)
        execute 'vsplit ' . fnameescape(a:file)
    else
        echo "File does not exist: " . a:file
    endif
    call cursor(a:line, l:col)
endfunction

function s:open_file_in_direction_at(file, line, col, direction)
    if empty(a:file)
        echo "No file under cursor"
        return
    endif

    if !filereadable(a:file)
        echo "File does not exist: " . a:file
        return
    endif

    execute "wincmd " . a:direction
    execute "edit " . fnameescape(a:file)

    call cursor(a:line, l:col)
endfunction


function! OpenFileInWindowInDirectionHAt(file, line, ...) abort
    let l:col = a:0 ? a:1 : 1
    call s:open_file_in_direction_at(a:file, a:line, l:col, 'h')
endfunction

function! OpenFileInWindowInDirectionJAt(file, line, ...) abort
    let l:col = a:0 ? a:1 : 1
    call s:open_file_in_direction_at(a:file, a:line, l:col, 'j')
endfunction

function! OpenFileInWindowInDirectionKAt(file, line, ...) abort
    let l:col = a:0 ? a:1 : 1
    call s:open_file_in_direction_at(a:file, a:line, l:col, 'k')
endfunction

function! OpenFileInWindowInDirectionLAt(file, line, ...) abort
    let l:col = a:0 ? a:1 : 1
    call s:open_file_in_direction_at(a:file, a:line, l:col, 'l')
endfunction
