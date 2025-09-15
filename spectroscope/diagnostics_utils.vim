let s:config_path = split(&runtimepath, ',')[0]
execute 'source' s:config_path . '/files_utils.vim'
function! OpenFileFromDiagnosticGeneric(diagnostic, ...)
    
    let l:direction = get(a:000, 0, '')   " '', 'v', 'h', etc.
    call OpenFileGeneric(a:diagnostic.filename, l:direction, a:diagnostic.range.end.line + 1)
endfunction


function! OpenFileFromDiagnosticVSplitRight(diagnostic)
    call OpenFileFromDiagnosticGeneric(a:diagnostic, 'v')
endfunction

function! OpenFileFromDiagnosticInDirectionH(diagnostic)
    call OpenFileFromDiagnosticGeneric(a:diagnostic, 'h')
endfunction

function! OpenFileFromDiagnosticInDirectionJ(diagnostic)
    call OpenFileFromDiagnosticGeneric(a:diagnostic, 'j')
endfunction

function! OpenFileFromDiagnosticInDirectionK(diagnostic)
    call OpenFileFromDiagnosticGeneric(a:diagnostic, 'k')
endfunction

function! OpenFileFromDiagnosticInDirectionL(diagnostic)
    call OpenFileFromDiagnosticGeneric(a:diagnostic, 'l')
endfunction

