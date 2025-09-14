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

function! ParseGrepLine(line)
    let m = matchlist(a:line, '\v^([^:]+):(\d+):(\d+):(.*)$')
    if !empty(m)
        return {
                    \ 'file': m[1],
                    \ 'line': str2nr(m[2]),
                    \ 'col': str2nr(m[3]),
                    \ 'text': m[4]
                    \ }
    endif
    let m = matchlist(a:line, '\v^([^:]+):(\d+):(.*)$')
    if !empty(m)
        return {
                    \ 'file': m[1],
                    \ 'line': str2nr(m[2]),
                    \ 'col': 0,
                    \ 'text': m[3]
                    \ }
    endif

    return {}
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

    call cursor(a:line, a:col)
endfunction


function! OpenFileWhereString(found_string_line)
    let l:parsed_line = ParseGrepLine(a:found_string_line)
    if empty(l:parsed_line)
        echoerr "Couldn't parse " . a:found_string_line
        return
    endif

    let l:file = l:parsed_line.file
    let l:line = l:parsed_line.line
    call OpenFileAt(l:file, l:line, get(l:parsed_line, 'col', 1))
endfunction

function! OpenFileWhereStringVSplitRight(found_string_line)
    let l:parsed_line = ParseGrepLine(a:found_string_line)
    if empty(l:parsed_line)
        echoerr "Couldn't parse " . a:found_string_line
        return
    endif
    let l:file = l:parsed_line.file
    let l:line = l:parsed_line.line
    call OpenFileVSplitRightAt(l:file, l:line, get(l:parsed_line, 'col', 1))
endfunction

function! OpenFileWhereStringInDirectionH(found_string_line)
    let l:parsed_line = ParseGrepLine(a:found_string_line)
    if empty(l:parsed_line)
        echoerr "Couldn't parse " . a:found_string_line
        return
    endif
    let l:file = l:parsed_line.file
    let l:line = l:parsed_line.line
    call s:open_file_in_direction_at(l:file, l:line, get(l:parsed_line, 'col', 1), 'h')
endfunction

function! OpenFileWhereStringInDirectionJ(found_string_line)
    let l:parsed_line = ParseGrepLine(a:found_string_line)
    if empty(l:parsed_line)
        echoerr "Couldn't parse " . a:found_string_line
        return
    endif
    let l:file = l:parsed_line.file
    let l:line = l:parsed_line.line
    call s:open_file_in_direction_at(l:file, l:line, get(l:parsed_line, 'col', 1), 'j')
endfunction

function! OpenFileWhereStringInDirectionK(found_string_line)
    let l:parsed_line = ParseGrepLine(a:found_string_line)
    if empty(l:parsed_line)
        echoerr "Couldn't parse " . a:found_string_line
        return
    endif
    let l:file = l:parsed_line.file
    let l:line = l:parsed_line.line
    call s:open_file_in_direction_at(l:file, l:line, get(l:parsed_line, 'col', 1), 'k')
endfunction

function! OpenFileWhereStringInDirectionL(found_string_line)
    let l:parsed_line = ParseGrepLine(a:found_string_line)
    if empty(l:parsed_line)
        echoerr "Couldn't parse " . a:found_string_line
        return
    endif
    let l:file = l:parsed_line.file
    let l:line = l:parsed_line.line
    call s:open_file_in_direction_at(l:file, l:line, get(l:parsed_line, 'col', 1), 'l')
endfunction

