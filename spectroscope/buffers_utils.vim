let s:config_path = split(&runtimepath, ',')[0]
execute 'source' s:config_path . '/buffers_utils.vim'

function! OpenBuffer(buffer_obj)
    call OpenBufferGeneric(a:buffer_obj.bufnr)
endfunction

function! OpenBufferVSplitRight(buffer_obj)
    call OpenBufferGeneric(a:buffer_obj.bufnr, 'v')
endfunction

function! OpenBufferInWindowInDirectionH(buffer_obj)
    call OpenBufferGeneric(a:buffer_obj.bufnr, 'h')
endfunction

function! OpenBufferInWindowInDirectionJ(buffer_obj)
    call OpenBufferGeneric(a:buffer_obj.bufnr, 'j')
endfunction

function! OpenBufferInWindowInDirectionK(buffer_obj)
    call OpenBufferGeneric(a:buffer_obj.bufnr, 'k')
endfunction

function! OpenBufferInWindowInDirectionL(buffer_obj)
    call OpenBufferGeneric(a:buffer_obj.bufnr, 'l')
endfunction

function! OpenBufferExternally(buffer_obj)
    if filereadable(a:buffer_obj.name)
        call OpenFileExternally(a:buffer_obj.name)
    else
        echoerr "File does not exist: " . a:buffer_obj.name
    endif
endfunction

