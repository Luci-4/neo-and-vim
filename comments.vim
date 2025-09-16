function! ToggleComment() range
    let l:ft = &filetype

    let l:prefix_map = {
                \ 'vim': '"',
                \ 'python': '#',
                \ 'c': '//',
                \ 'cpp': '//',
                \ 'javascript': '//',
                \ 'lua': '--',
                \ }

    let l:prefix = get(l:prefix_map, l:ft, '//')

    let l:pat = '^' . escape(l:prefix, '\.^$*~[]')

    if mode() =~# 'v'
        let l:start = line("'<")
        let l:end = line("'>")
    else
        let l:start = a:firstline
        let l:end = a:lastline
    endif

    let l:lines = getline(l:start, l:end)

    let l:all_commented = len(filter(copy(l:lines), {_, v -> v !~# l:pat})) == 0

    let l:escaped_prefix = escape(l:prefix, '\#')
    if l:all_commented
        execute l:start . ',' . l:end . 's#' . l:pat . '##'
    else
        execute l:start . ',' . l:end . 's#^#' . l:escaped_prefix . '#'
    endif
endfunction
