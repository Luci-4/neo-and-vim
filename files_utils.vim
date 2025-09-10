function! OpenFileExternally(file)
    let l:file = expand(a:file)
    if empty(l:file)
        echo "No file to open"
        return
    endif

    if has('win32') || has('win64')
        let l:cmd = 'start "" ' . shellescape(l:file)
    elseif has('macunix')
        let l:cmd = 'open ' . shellescape(l:file)
    elseif has('unix')
        let l:cmd = 'xdg-open ' . shellescape(l:file)
    else
        echo "Unsupported OS"
        return
    endif

    call system(l:cmd)
    echo "Opened " . l:file . " externally"
endfunction

function! s:find_files_in_cwd_windows_cmd(blacklist) abort
    let l:cwd = getcwd()
    let l:pattern = join(map(copy(a:blacklist), 'escape(v:val, ".")'), '\|')
    let l:cmd = 'cmd /v /c "for /r ""'.l:cwd.'"" %F in (*) do @set "rel=%F" & echo !rel:'.l:cwd.'\=!"" | findstr /i /v /r ""'.l:pattern.'"""'
    echom l:cmd
    let l:result = systemlist(l:cmd)
    return l:result
endfunction


function! FindFilesInCWDSystemBased(blacklist)
    let l:root = getcwd()
    let l:blacklist = a:blacklist

    if IsOnLinux()
        if executable('find')
            let l:exclude = join(map(copy(l:blacklist), {idx, val -> "-not -name '".val."'"}), ' ')
            let l:cmd = printf("find %s -type f %s -name '%s'", shellescape(l:root), l:exclude, '**/*')
            return systemlist(l:cmd)
        endif
    elseif IsOnWindows()
        if executable('powershell')
            return s:find_files_in_cwd_windows_cmd(l:blacklist)
        endif
    endif

    let l:files = globpath(l:root, '**/*', 0, 1)
    if !empty(l:blacklist)
        let l:files = filter(copy(l:files), 'empty(filter(l:blacklist, "match(v:val, v:val1)"))')
    endif
    return l:files
endfunction
