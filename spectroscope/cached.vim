if !exists("g:files_cached")
    let g:files_cached = []
endif
if !exists("g:blacklist_args_cached_for_tools")
    let g:blacklist_args_cached_for_tools = {}
endif


function! TryInitSpectroscopePickerCache()
    if !exists("g:spectroscope_picker_previous_query")
        let g:spectroscope_picker_previous_query = {} " strings
    endif
    if !exists("g:spectroscope_picker_previous_results")
        let g:spectroscope_picker_previous_results = {} " lists
    endif
    if !exists("g:spectroscope_picker_all_previous_results")
        let g:spectroscope_picker_all_previous_results = {} " maps
    endif
endfunction

function! ClearSpectroscopePickerCache(filename)
    call TryInitSpectroscopePickerCache()
    let g:spectroscope_picker_previous_query[a:filename] = ''
    let g:spectroscope_picker_previous_results[a:filename] = []
    let g:spectroscope_picker_all_previous_results[a:filename] = {}
endfunction


