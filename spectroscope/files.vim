let s:config_path = split(&runtimepath, ',')[0]

execute 'source' s:config_path . '/spectroscope/spectroscope.vim'
execute 'source' s:config_path . './spectroscope/bind_groups.vim'
execute 'source' s:config_path . './spectroscope/cached.vim'


function! FileFilterCallback(list, input)
    let l:list = 
    let input = a:input
    let filtered_list = filter(copy(list), 'v:val =~# input')
    call sort(filtered_list, {a, b -> len(a) - stridx(a, input) - (len(b) - stridx(b, input))})
    return filtered_list
endfunction

function! FilterList(bufnr, pattern)
    if a:pattern ==# ''
        let l:filtered = s:current_list
    else
        let l:filtered = filter(copy(s:current_list), 'v:val =~ a:pattern')
    endif

    call setbufvar(a:bufnr, '&modifiable', 1)
    call setbufline(a:bufnr, 1, l:filtered)
    call deletebufline(a:bufnr, len(l:filtered) + 1, '$')
    call setbufvar(a:bufnr, '&modifiable', 0)
endfunction

function! FindFiles()
    let l:files = g:files_cached

    if empty(l:files)
        echom "looking for them again"
        let l:files = FindFilesInCWDSystemBased()
    endif

    if !empty(l:files)
        call OpenSpecialListBuffer(l:files, g:spectroscope_files_binds, 'filelist', 1)
    else
        echo "No files found in current directory."
    endif
endfunction
function! FindFilesWithFilter()
    let l:files = g:files_cached
    if empty(l:files)
        let l:files = FindFilesInCWDSystemBased()
    endif

    if !empty(l:files)

        call OpenSpecialListBufferPicker(l:files, g:spectroscope_picker_binds_files_directions, 'FileFilterCallback', 'filelist', 0, 0)
    else
        echo "No files found in current directory."
    endif
endfunction

function! LastFileWithFilter()
    let l:files = g:files_cached
    if empty(l:files)
        let l:files = FindFilesInCWDSystemBased()
    endif

    if !empty(l:files)
        call OpenSpecialListBufferPicker(l:files, g:spectroscope_picker_binds_files_directions, 'FileFilterCallback', 'filelist', 0, 1)
    else
        echo "No files found in current directory."
    endif
endfunction
