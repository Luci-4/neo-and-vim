function! OpenFile(file)
    call OpenFileGeneric(a:file)
endfunction

function! OpenFileVSplitRight(file)
    call OpenFileGeneric(a:file, 'v')
endfunction

function! OpenFileInWindowInDirectionH(file)
    call OpenFileGeneric(a:file, 'h')
endfunction

function! OpenFileInWindowInDirectionJ(file)
    call OpenFileGeneric(a:file, 'j')
endfunction

function! OpenFileInWindowInDirectionK(file)
    call OpenFileGeneric(a:file, 'k')
endfunction

function! OpenFileInWindowInDirectionL(file)
    call OpenFileGeneric(a:file, 'l')
endfunction

