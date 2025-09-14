let s:config_path = split(&runtimepath, ',')[0]

function! FindFilesInCWDSystemBased()
    let l:root = getcwd()
    let l:files = []

    if executable('fd')
        let l:cmd = 'fd . --type f --hidden --follow' . g:blacklist_args_cached_for_tools['fd'] . ' --base-directory ' . shellescape(l:root)
        let l:files = split(system(l:cmd), "\n")
        echom "running fd: " . l:cmd
        return l:files

    if IsOnLinux()
        elseif executable('rg')
            let l:files = split(system('rg --files --hidden --follow ' . g:blacklist_args_cached_for_tools['rg'] . ' ' . shellescape(l:root)), "\n")
            return l:files
        elseif executable('find')
            let l:files = split(system('find ' . shellescape(l:root) . ' -type f' . g:blacklist_args_cached_for_tools['find']), "\n")
            return l:files
        endif
    endif
    let l:files = globpath(l:root, '**/*', 0, 1) 
    if !empty(l:blacklist_directories)
        for dir in g:blacklist_directories
            let l:files = filter(l:files, 'v:val !~# "/" . dir . "/"')
        endfor
    endif
    for pattern in g:blacklist_files
        let l:files = filter(l:files, 'v:val !~# pattern_to_regex(pattern)')
    endfor
    return l:files
endfunction
