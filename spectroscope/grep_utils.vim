let s:config_path = split(&runtimepath, ',')[0]
execute 'source' s:config_path . '/files_utils.vim'


function! GrepInCWDSystemBased(needle) abort
    let l:files = g:files_cached
    let l:use_black_list = 0
    if empty(l:files)
        let l:use_black_list = 1
        " let l:files = FindFilesInCWDSystemBased()
    endif

    let l:root = getcwd()
    let l:needle = a:needle
    let l:results = []
    if empty(l:needle)
        return l:results
    endif

    if executable('rg')
        if l:use_black_list
            let l:cmd = 'rg --vimgrep --column --hidden --follow ' . g:blacklist_args_cached_for_tools['rg'] . ' ' . shellescape(l:needle) . ' ' . shellescape(l:root)
        else
            let l:cmd = "rg --vimgrep --column --hidden -- " . shellescape(a:needle) . ' ' . join(g:files_cached_shell_escaped, ' ')
        endif
        let l:results = split(system(l:cmd), "\n")
        echom "used rg, collected " . len(l:results)
        return l:results
    endif

    if IsOnLinux() && executable('grep')
        if l:use_black_list
            let l:cmd = 'grep -RnH ' . g:blacklist_args_cached_for_tools['grep'] . ' ' . shellescape(l:needle) . ' ' . shellescape(l:root)
        else
            let cmd = 'grep -nH -e ' . shellescape(a:needle) . ' ' . join(g:files_cached_shell_escaped, ' ')
        endif

        let l:results = split(systemlist(l:cmd), '\n')

        echom "used grep, collected " . len(l:results)
        return l:results
    endif
    call setqflist([])

    let file_list = join(l:files, ' ')

    let pattern = escape(a:needle, '/\.*$^~[]')
    execute 'vimgrep /' . pattern . '/j ' . file_list

    for item in getqflist()
        " Construct the standard format string
        let entry = printf('%s:%d:%d:%s', item.bufname, item.lnum, item.col, item.text)
        call add(results, entry)
    endfor

    echom "used vimgrep, collected " . len(l:results)
    return results
endfunction


function! s:parse_grep_line(line)
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
function! OpenFileWhereString(found_string_line)
    let l:parsed_line = s:parse_grep_line(a:found_string_line)
    if empty(l:parsed_line)
        echoerr "Couldn't parse " . a:found_string_line
        return
    endif

    let l:file = l:parsed_line.file
    let l:line = l:parsed_line.line
    call OpenFileAt(l:file, l:line, get(l:parsed_line, 'col', 1))
endfunction

function! OpenFileWhereStringVSplitRight(found_string_line)
    let l:parsed_line = s:parse_grep_line(a:found_string_line)
    if empty(l:parsed_line)
        echoerr "Couldn't parse " . a:found_string_line
        return
    endif
    let l:file = l:parsed_line.file
    let l:line = l:parsed_line.line
    call OpenFileVSplitRightAt(l:file, l:line, get(l:parsed_line, 'col', 1))
endfunction

function! OpenFileWhereStringInDirectionH(found_string_line)
    let l:parsed_line = s:parse_grep_line(a:found_string_line)
    if empty(l:parsed_line)
        echoerr "Couldn't parse " . a:found_string_line
        return
    endif
    let l:file = l:parsed_line.file
    let l:line = l:parsed_line.line
    call s:open_file_in_direction(l:file, l:line, get(l:parsed_line, 'col', 1), 'h')
endfunction

function! OpenFileWhereStringInDirectionJ(found_string_line)
    let l:parsed_line = s:parse_grep_line(a:found_string_line)
    if empty(l:parsed_line)
        echoerr "Couldn't parse " . a:found_string_line
        return
    endif
    let l:file = l:parsed_line.file
    let l:line = l:parsed_line.line
    call s:open_file_in_direction(l:file, l:line, get(l:parsed_line, 'col', 1), 'j')
endfunction

function! OpenFileWhereStringInDirectionK(found_string_line)
    let l:parsed_line = s:parse_grep_line(a:found_string_line)
    if empty(l:parsed_line)
        echoerr "Couldn't parse " . a:found_string_line
        return
    endif
    let l:file = l:parsed_line.file
    let l:line = l:parsed_line.line
    call s:open_file_in_direction(l:file, l:line, get(l:parsed_line, 'col', 1), 'k')
endfunction

function! OpenFileWhereStringInDirectionL(found_string_line)
    let l:parsed_line = s:parse_grep_line(a:found_string_line)
    if empty(l:parsed_line)
        echoerr "Couldn't parse " . a:found_string_line
        return
    endif
    let l:file = l:parsed_line.file
    let l:line = l:parsed_line.line
    call s:open_file_in_direction(l:file, l:line, get(l:parsed_line, 'col', 1), 'l')
endfunction

