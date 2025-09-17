let s:config_path = split(&runtimepath, ',')[0]
execute 'source' s:config_path . '/files_utils.vim'
function! OpenFileFromDiagnosticGeneric(diagnostic, ...)
    
    let l:direction = get(a:000, 0, '')   " '', 'v', 'h', etc.
    call OpenFileGeneric(a:diagnostic.filename, l:direction, a:diagnostic.end_line)
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


function! FormatDiagnosticForList(diag)
        return a:diag.sign . ' ' . a:diag.msg . ' : ' . a:diag.filename . ':' . a:diag.end_line
    "let l:filepath = a:diag.filename
    "let l:end_line  = a:diag.range.end.line + 1
    "let l:msg       = a:diag.message
    "let l:sev       = a:diag.severity
"
    "let l:diag_props = s:get_diagnostic_props_from_severity(l:sev)
    "let l:sign_text = l:diag_props.sign_text
    "let l:hl_group  = l:diag_props.hl_group 
    "let l:sign_name = l:diag_props.sign_name
    "let l:prop_type = l:diag_props.prop_type
    "let relpath = fnamemodify(l:filepath, ':.')
    "return l:sign_text . ' ' . l:msg . ' : ' . relpath . ':' . l:end_line  
endfunction
