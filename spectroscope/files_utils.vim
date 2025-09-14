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

