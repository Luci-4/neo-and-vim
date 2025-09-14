function! IsOnLinux()
    if !has('unix')
        return 0
    endif

    if has('linux')
        return 1
    endif

    let l:ostype = get($, 'OSTYPE', '')
    if l:ostype =~? 'linux'
        return 1
    endif

    let l:machtype = get($, 'MACHTYPE', '')
    if l:machtype =~? 'linux'
        return 1
    endif

    return 0
endfunction

function! IsOnWindows() 
    return has('win32') || has('win64')
endfunction

function! TernaryIfLinux(linux_version, other_version)
    if IsOnLinux()
        return a:linux_version
    else
        return a:other_version
    endif
endfunction
