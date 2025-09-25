let s:config_path = split(&runtimepath, ',')[0]

execute 'source' s:config_path . '/spectroscope/spectroscope.vim'
execute 'source' s:config_path . '/spectroscope/bind_groups.vim'
execute 'source' s:config_path . '/spectroscope/cached.vim'

function! GrepFilterCallback(list, input)
    " let input = a:input
    " return filter(copy(a:list), 'v:val =~# input')
    return GrepInCWDSystemBased(a:input)
endfunction

function! GrepPatternCallback(input)
    return '\v^([^:]*:){2}.*\zs\V' . escape(a:input, '\')
endfunction

function! FindStringWithFilter()

    call OpenSpecialListBufferPicker([], '', g:spectroscope_grep_binds, 'GrepFilterCallback',  'greplist', 0, 0, 0, g:spectroscope_grep_binds, '', 'GrepPatternCallback')
endfunction

function! FindStringWordUnderCursorWithFilter()
    let word_under_cursor = expand('<cword>')
    call OpenSpecialListBufferPicker([], word_under_cursor, g:spectroscope_grep_binds, 'GrepFilterCallback',  'greplist', 0, 0, 0, g:spectroscope_grep_binds, 'GrepPatternCallback')
endfunction
