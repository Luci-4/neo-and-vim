let s:config_path = split(&runtimepath, ',')[0]
execute 'source' s:config_path . '/spectroscope/spectroscope.vim'
execute 'source' s:config_path . '/spectroscope/bind_groups.vim'

let g:files_spectroscope_file_type = 'terminals'


function! FormatFromTerminalBufnr(bufnr)
    return printf("buf %d", a:bufnr)
endfunction

function! ListTerminals()
    let l:terminals = filter(range(1, bufnr('$')), 'bufexists(v:val) && getbufvar(v:val, "&buftype") ==# "terminal"')
    if !empty(l:terminals)
        call OpenSpecialListBuffer(l:terminals, g:spectroscope_terminal_binds, g:files_spectroscope_file_type, 1, 0, "FormatFromTerminalBufnr")
    else
        echo "No terminals found in current directory."
    endif
endfunction
