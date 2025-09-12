let s:config_path = split(&runtimepath, ',')[0]

execute 'source' s:config_path . '/spectroscope/spectroscope.vim'
execute 'source' s:config_path . './spectroscope/bind_groups.vim'
execute 'source' s:config_path . './spectroscope/cached.vim'


let s:previous_input = ''
let s:previous_results = []

function! FileFilterCallback(list, input)
    if empty(a:input)
        return a:input
    endif
    let l:list = a:list 
    let input = a:input
    if !empty(s:previous_results)
        if stridx(input, s:previous_input) == 0 && strlen(input) > strlen(s:previous_input)
            let filtered_list = filter(copy(s:previous_results), 'v:val =~# input')
            let s:previous_input = input
            let s:previous_results = l:filtered_list
            return filtered_list
        endif
    endif
    let filtered_list = filter(copy(list), 'v:val =~# input')
    call sort(filtered_list, {a, b -> len(a) - stridx(a, input) - (len(b) - stridx(b, input))})
    return filtered_list
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

        call OpenSpecialListBufferPicker(l:files, '', g:spectroscope_picker_binds_files_directions, 'FileFilterCallback', 'filelist', 0, 0)
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
        call OpenSpecialListBufferPicker(l:files, '', g:spectroscope_picker_binds_files_directions, 'FileFilterCallback', 'filelist', 0, 1)
    else
        echo "No files found in current directory."
    endif
endfunction
