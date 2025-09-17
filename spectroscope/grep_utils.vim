let s:config_path = split(&runtimepath, ',')[0]
execute 'source' s:config_path . '/files_utils.vim'
execute 'source' s:config_path . '/spectroscope/vimgrep_utils.vim'
execute 'source' s:config_path . '/spectroscope/cached.vim'
execute 'source' s:config_path . '/spectroscope/blacklist_args_cache.vim'


let g:grep_spectroscope_file_type = 'greplist'

function! GrepInCWDSystemBased(needle) abort
    if len(a:needle) < 3
        return []
    endif
    if !empty(g:spectroscope_picker_previous_results[g:grep_spectroscope_file_type])
        let l:previous_query = g:spectroscope_picker_previous_query[g:grep_spectroscope_file_type]
        if stridx(a:needle, l:previous_query) == 0 && strlen(a:needle) > strlen(l:previous_query)
            let l:filtered = []
            for l:line in g:spectroscope_picker_previous_results[g:grep_spectroscope_file_type]
                let l:parsed = ParseGrepLine(l:line)
                if !empty(l:parsed) && l:parsed.text =~ a:needle
                    call add(l:filtered, l:line)
                endif
            endfor
            let g:spectroscope_picker_previous_query[g:grep_spectroscope_file_type] = a:needle
            let g:spectroscope_picker_previous_results[g:grep_spectroscope_file_type] = l:filtered

            if !has_key(g:spectroscope_picker_all_previous_results[g:grep_spectroscope_file_type], a:needle)
                let g:spectroscope_picker_all_previous_results[g:grep_spectroscope_file_type][a:needle] = l:filtered
            endif

            return l:filtered
        endif
    endif
    if has_key(g:spectroscope_picker_all_previous_results[g:grep_spectroscope_file_type], a:needle)
        return g:spectroscope_picker_all_previous_results[g:grep_spectroscope_file_type][a:needle]
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
        if l:use_black_list == 1
            let l:cmd = 'rg --vimgrep --column --hidden --follow ' . g:blacklist_args_cached_for_tools['rg'] . ' ' . shellescape(l:needle) . ' ' . shellescape(l:root)
        else
            let l:cmd = "rg --vimgrep --column --hidden -- " . shellescape(a:needle) . ' ' . join(g:files_cached_shell_escaped, ' ')
        endif
        let l:sys_output = system(l:cmd)
        
        let l:results = split(substitute(l:sys_output, '\s\+', ' ', 'g'), "\n")

    elseif IsOnLinux() && executable('grep')
        if l:use_black_list
            let l:cmd = 'grep -RnH ' . g:blacklist_args_cached_for_tools['grep'] . ' ' . shellescape(l:needle) . ' ' . shellescape(l:root)
        else
            let cmd = 'grep -nH -e ' . shellescape(a:needle) . ' ' . join(g:files_cached_shell_escaped, ' ')
        endif

        
        let l:sys_output = systemlist(l:cmd)
        if type(l:sys_output) == type([])
            let l:results = l:sys_output
        elseif type(l:sys_output) == type('')
            let l:results = split(substitute(l:sys_output, '\s\+', ' ', 'g'), '\n')
        else
            let l:results = []
        endif
        return l:results

    else
        call setqflist([])

        let file_list = join(l:files, ' ')

        let pattern = escape(a:needle, '/\.*$^~[]')
        execute 'vimgrep /' . pattern . '/j ' . file_list

        for item in getqflist()

            let entry = printf('%s:%d:%d:%s', item.bufname, item.lnum, item.col, substitute(item.text, '\s\+', ' ', 'g'))
            call add(l:results, entry)
        endfor
    endif
    let g:spectroscope_picker_previous_query[g:grep_spectroscope_file_type] = a:needle
    let g:spectroscope_picker_previous_results[g:grep_spectroscope_file_type] = l:results

    if !has_key(g:spectroscope_picker_all_previous_results[g:grep_spectroscope_file_type], a:needle)
        let g:spectroscope_picker_all_previous_results[g:grep_spectroscope_file_type][a:needle] = l:results
    endif
    return l:results
endfunction


