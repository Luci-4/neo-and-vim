let g:files_cached = []
let g:blacklist_args_cached_for_tools = {}

let g:spectroscope_picker_previous_query = {} " strings
let g:spectroscope_picker_previous_results = {} " lists
let g:spectroscope_picker_all_previous_results = {} " maps

function! ClearSpectroscopePickerCache(filename)
    if !exists('g:spectroscope_picker_previous_query')
        let g:spectroscope_picker_previous_query = {}
    endif
    if !exists('g:spectroscope_picker_previous_results')
        let g:spectroscope_picker_previous_results = {}
    endif
    if !exists('g:spectroscope_picker_all_previous_results')
        let g:spectroscope_picker_all_previous_results = {}
    endif

    let g:spectroscope_picker_previous_query[a:filename] = ''
    let g:spectroscope_picker_previous_results[a:filename] = []
    let g:spectroscope_picker_all_previous_results[a:filename] = {}
endfunction


