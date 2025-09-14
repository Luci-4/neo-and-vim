let s:config_path = split(&runtimepath, ',')[0]

function! FindFilesInCWDSystemBased()
    let l:root = getcwd()
    let l:files = []

    if !empty(g:files_cached)
        return g:files_cached
    endif

    if executable('fd')
        let l:cmd = 'fd . --type f --hidden --follow' .
                    \ g:blacklist_args_cached_for_tools['fd'] .
                    \ ' --base-directory ' . shellescape(l:root)
        let l:files = split(system(l:cmd), "\n")
        return l:files
    endif


    let l:files = globpath(l:root, '**/*', 0, 1)

    if !empty(g:blacklist_directories)
        for dir in g:blacklist_directories
            let l:files = filter(l:files, 'v:val !~# "/" . dir . "/"')
        endfor
    endif

    for pattern in g:blacklist_files
        let l:files = filter(l:files, 'v:val !~# pattern_to_regex(pattern)')
    endfor

    let l:files = filter(l:files, 'v:val =~# "^" . escape(l:root, "/\\")')
    let l:files = map(l:files, 'fnamemodify(v:val, ":.")')
    return l:files
endfunction
