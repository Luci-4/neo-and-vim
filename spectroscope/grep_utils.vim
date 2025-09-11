let s:config_path = split(&runtimepath, ',')[0]
execute 'source' s:config_path . '/files_utils.vim'


let s:previous_needle = ''
let s:previous_results = [] 

function! GrepInCWDSystemBased(needle) abort
    if len(a:needle) < 3
        return []
    endif
    if !empty(s:previous_results)
        if stridx(a:needle, s:previous_needle) == 0 && strlen(a:needle) > strlen(s:previous_needle)
            let l:filtered = []
            for l:line in s:previous_results
                let l:parsed = s:parse_grep_line(l:line)
                if !empty(l:parsed) && l:parsed.text =~ a:needle
                    call add(l:filtered, l:line)
                endif
            endfor
            let s:previous_needle = a:needle
            let s:previous_results = l:filtered
            return l:filtered
        endif
    endif
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

    elseif IsOnLinux() && executable('grep')
        if l:use_black_list
            let l:cmd = 'grep -RnH ' . g:blacklist_args_cached_for_tools['grep'] . ' ' . shellescape(l:needle) . ' ' . shellescape(l:root)
        else
            let cmd = 'grep -nH -e ' . shellescape(a:needle) . ' ' . join(g:files_cached_shell_escaped, ' ')
        endif

        let l:results = split(systemlist(l:cmd), '\n')

    else
        call setqflist([])

        let file_list = join(l:files, ' ')

        let pattern = escape(a:needle, '/\.*$^~[]')
        execute 'vimgrep /' . pattern . '/j ' . file_list

        for item in getqflist()
            " Construct the standard format string
            let entry = printf('%s:%d:%d:%s', item.bufname, item.lnum, item.col, item.text)
            call add(l:results, entry)
        endfor
    endif
    let s:previous_needle = a:needle
    let s:previous_results = l:results
    return l:results
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

