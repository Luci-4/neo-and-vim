let s:config_path = split(&runtimepath, ',')[0]
execute 'source' s:config_path . '/files_utils.vim'

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



function! OpenFileFromGrepStringGeneric(grep_string_line, ...)
    let l:parsed_line = ParseGrepLine(a:grep_string_line)
    if empty(l:parsed_line)
        echoerr "Couldn't parse " . a:grep_string_line
        return
    endif

    let l:direction = get(a:000, 0, '')   " '', 'v', 'h', etc.
    call OpenFileGeneric(l:parsed_line.file, l:direction, l:parsed_line.line, get(l:parsed_line, 'col', 1))
endfunction


function! OpenFileFromGrepStringVSplitRight(found_string_line)
    call OpenFileFromGrepStringGeneric(a:found_string_line, 'v')
endfunction

function! OpenFileFromGrepStringInDirectionH(found_string_line)
    call OpenFileFromGrepStringGeneric(a:found_string_line, 'h')
endfunction

function! OpenFileFromGrepStringInDirectionJ(found_string_line)
    call OpenFileFromGrepStringGeneric(a:found_string_line, 'j')
endfunction

function! OpenFileFromGrepStringInDirectionK(found_string_line)
    call OpenFileFromGrepStringGeneric(a:found_string_line, 'k')
endfunction

function! OpenFileFromGrepStringInDirectionL(found_string_line)
    call OpenFileFromGrepStringGeneric(a:found_string_line, 'l')
endfunction

