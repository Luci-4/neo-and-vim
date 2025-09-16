let s:config_path = split(&runtimepath, ',')[0]

execute 'source' s:config_path . '/spectroscope/spectroscope.vim'
execute 'source' s:config_path . '/spectroscope/bind_groups.vim'
execute 'source' s:config_path . '/spectroscope/cached.vim'


let g:files_spectroscope_file_type = 'filelist'


function! FileFilterCallback(list, input)
    if empty(a:input)
        return a:input
    endif
    let l:list = a:list 
    let input = a:input
    if !empty(g:spectroscope_picker_previous_results[g:files_spectroscope_file_type])
        let l:previous_query = g:spectroscope_picker_previous_query[g:files_spectroscope_file_type] 
        if stridx(input, l:previous_query) == 0 && strlen(input) > strlen(l:previous_query)
            let filtered_list = filter(copy(g:spectroscope_picker_previous_results[g:files_spectroscope_file_type]), 'v:val =~# input')
            let g:spectroscope_picker_previous_query[g:files_spectroscope_file_type] = input
            let g:spectroscope_picker_previous_results[g:files_spectroscope_file_type] = l:filtered_list
            if !has_key(g:spectroscope_picker_all_previous_results[g:files_spectroscope_file_type], input)
                let g:spectroscope_picker_all_previous_results[g:files_spectroscope_file_type][input] = l:filtered_list
            endif
            return filtered_list
        endif
    endif

    if has_key(g:spectroscope_picker_all_previous_results[g:files_spectroscope_file_type], input)
        return g:spectroscope_picker_all_previous_results[g:files_spectroscope_file_type][input]
    endif
    let filtered_list = filter(copy(list), 'v:val =~# input')
    call sort(filtered_list, {a, b -> len(a) - stridx(a, input) - (len(b) - stridx(b, input))})
    return filtered_list
endfunction

function! FindFiles()
    let l:files = g:files_cached

    if empty(l:files)
        let l:files = FindFilesInCWDSystemBased()
    endif

    if !empty(l:files)
        call OpenSpecialListBuffer(l:files, g:spectroscope_files_binds, g:files_spectroscope_file_type, 1, 0)
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

        call OpenSpecialListBufferPicker(l:files, '', g:spectroscope_picker_binds_files_directions, 'FileFilterCallback', g:files_spectroscope_file_type, 0, 0, 0, g:spectroscope_files_binds)
    else
        echo "No files found in current directory."
    endif
endfunction

function! LastFilesWithFilter()
    let l:files = g:files_cached
    if empty(l:files)
        let l:files = FindFilesInCWDSystemBased()
    endif

    if !empty(l:files)
        call OpenSpecialListBufferPicker(l:files, '', g:spectroscope_picker_binds_files_directions, 'FileFilterCallback', g:files_spectroscope_file_type, 0, 1, 0, g:spectroscope_files_binds)
    else
        echo "No files found in current directory."
    endif
endfunction
