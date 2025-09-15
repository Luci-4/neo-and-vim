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
    let prefix = get(l:prefix_map, l:ft, '//')
    let pat = '^' . escape(prefix, '\.^$*~[]')

    if mode() =~# 'v'
        let start = line("'<")
        let end = line("'>")
    else
        let start = a:firstline
        let end = a:lastline
    endif

    let lines = getline(start, end)

    if empty(filter(copy(lines), {_, v -> v !~# pat}))
        execute start . ',' . end . 's/' . pat . '//'
    else
        execute start . ',' . end . 'normal! I' . prefix
    endif
endfunction
