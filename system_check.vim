function! IsOnLinux()
    return has('unix') && executable('uname') && system('uname -s') =~? '^linux'
endfunction

function! TernaryIfLinux(linux_version, other_version)
    if IsOnLinux()
        return a:linux_version
    else
        return a:other_version
    endif
endfunction
