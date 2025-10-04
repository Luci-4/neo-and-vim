let s:config_path = split(&runtimepath, ',')[0]

execute 'source' s:config_path . '/spectroscope/spectroscope.vim'
execute 'source' s:config_path . '/spectroscope/bind_groups.vim'
function! FormatBufferRelative(buf) abort
    let l:root = getcwd()
    let bufnr = a:buf.bufnr

    let linecount = a:buf.linecount

    let lastused = strftime('%Y-%m-%d %H:%M:%S', a:buf.lastused)

    if empty(a:buf.name)
        let relname = '[No Name]'
    else
        let relname = fnamemodify(a:buf.name, ':~:.')
        if l:root !=# '' && stridx(a:buf.name, l:root) == 0
            let relname = a:buf.name[len(l:root)+1 :]
        endif
    endif

    return printf('%3d  %-19s  %5d  %s', bufnr, lastused, linecount, relname)
endfunction

function! ListBuffers()
    let buffers = filter(
          \ getbufinfo({'buflisted': 1}),
          \ {_, v -> v.name !=# ''})
    let buffers = sort(buffers, {a,b -> b.lastused - a.lastused})
    " for buf in buffers
        " echom FormatBufferRelative(buf)
    " endfor
    call OpenSpecialListBuffer(buffers, g:spectroscope_buffers_binds, "bufferinfo", 0, 0, "FormatBufferRelative")
endfunction


