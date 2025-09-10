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


function! s:ExcludeArgs(tool, blacklist)
    let l:blacklist = a:blacklist
    let l:args = ''
    for item in l:blacklist
        if a:tool ==# 'fd'
            let l:args .= ' --exclude ' . shellescape(item)
        elseif a:tool ==# 'rg'
            let l:args .= ' --glob ' . shellescape('!' . item)
        elseif a:tool ==# 'find'
            let l:args .= ' ! -path ' . shellescape('*' . item . '*')
        endif
    endfor
    return l:args
endfunction

function! FindFilesInCWDSystemBased(blacklist)
    let l:root = getcwd()
    let l:blacklist = a:blacklist
    let l:files = []


    if IsOnLinux()
        if executable('fd')
            let l:exclude = s:ExcludeArgs('fd', l:blacklist)
            let l:files = split(system('fd . --type f --hidden --follow' . l:exclude . '--base-directory ' . shellescape(l:root)), "\n")
            return l:files
        elseif executable('rg')
            let l:exclude = s:ExcludeArgs('rg', l:blacklist)
            let l:files = split(system('rg --files --hidden --follow ' . l:exclude . ' ' . shellescape(l:root)), "\n")
            return l:files
        elseif executable('find')
            let l:exclude = s:ExcludeArgs('find', l:blacklist)
            let l:files = split(system('find ' . shellescape(l:root) . ' -type f' . l:exclude), "\n")
            return l:files
        endif
    elseif IsOnWindows()
        if executable('fd')
            let l:exclude = s:ExcludeArgs('fd', l:blacklist)

            let l:files = split(system('fd . --type f --hidden --follow' . l:exclude . ' --base-directory ' . shellescape(l:root)), "\n")
            return l:files
        endif
    endif

    let l:files = globpath(l:root, '**/*', 0, 1) 
    if !empty(l:blacklist)
        let l:files = filter(copy(l:files), 'empty(filter(l:blacklist, "match(v:val, v:val1)"))')
    endif
    return l:files
endfunction
