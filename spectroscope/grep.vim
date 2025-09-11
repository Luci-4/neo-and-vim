let s:config_path = split(&runtimepath, ',')[0]

execute 'source' s:config_path . '/spectroscope/spectroscope.vim'
execute 'source' s:config_path . './spectroscope/bind_groups.vim'
execute 'source' s:config_path . './spectroscope/cached.vim'

function! GrepFilterCallback(list, input)
    " let input = a:input
    " return filter(copy(a:list), 'v:val =~# input')
    return GrepInCWDSystemBased(a:input)
endfunction

function! FindStringWithFilter()
    call OpenSpecialListBufferPicker([], g:spectroscope_picker_binds_grep_directions, 'GrepFilterCallback',  'greplist', 0, 0)
endfunction
