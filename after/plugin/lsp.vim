let s:config_path = split(&runtimepath, ',')[0]
execute 'source' s:config_path . '/system_check.vim'
let g:lsp_file_patterns = ['*.c', '*.cpp', '*.h', '*.hpp']

function! LSPHover() abort
    let l:msg = {
    \ 'jsonrpc': '2.0',
    \ 'id': 4,
    \ 'method': 'textDocument/hover',
    \ 'params': {
    \   'textDocument': {'uri': s:lsp_text_document_uri()},
    \   'position': s:lsp_position()
    \ }
    \ }
    call ch_sendexpr(g:lsp_job, l:msg, {'callback': function('s:lsp_handle_hover')})
endfunction

function! s:lsp_handle_hover(channel, msg) abort
    if has_key(a:msg, 'error') && has_key(a:msg.error, 'message')
        echoerr a:msg.error.message
        return
    endif
    if has_key(a:msg, 'result') && has_key(a:msg.result, 'contents')
        let l:contents = a:msg.result.contents
        let l:texts = []

        if type(l:contents) == type([])
            for c in l:contents
                if type(c) == type({})
                    call add(l:texts, get(c, 'value', ''))
                else
                    call add(l:texts, c)
                endif
            endfor
        elseif type(l:contents) == type({})
            call add(l:texts, get(l:contents, 'value', ''))
        else
            call add(l:texts, l:contents)
        endif

        let l:lines = []
        for t in l:texts
            let t_clean = substitute(t, '\^@', "\n", 'g')
            call extend(l:lines, split(t_clean, "\n"))
        endfor

        call filter(l:lines, 'v:val !=# ""')
        let l:lines = map(l:lines, 'trim(v:val)')

        if empty(l:lines)
            echom "No hover info"
            return
        endif

        if exists('s:hover_popup') && s:hover_popup > 0
            call popup_close(s:hover_popup)

        endif

        let s:hover_popup = popup_create(l:lines, {
        \ 'pos': 'botleft',
        \ 'line': 'cursor+1',
        \ 'col': 'cursor',
        \ 'wrap': v:true,
        \ 'border': [],
        \ 'padding': [0,1,0,1],
        \ 'highlight': 'Normal',
        \ 'borderhighlight': ['MoreMsg'],
        \ 'mapping': v:true,
        \ 'filter': function('s:hover_popup_filter')
        \ })
    else
        echom "No hover info"
    endif
endfunction

function! s:hover_popup_filter(popup_id, key) abort
    if a:key =~# '\v(\cC|q)'
        if exists('s:hover_popup') && s:hover_popup > 0
            call popup_close(s:hover_popup)
            let s:hover_popup = 0
        endif
        return 1  
    endif
    return 0 
endfunction

function! s:lsp_position() abort
    let l:line = line('.') - 1
    let l:col  = col('.') - 1
    return {'line': l:line, 'character': l:col}
endfunction

function! s:lsp_text_document_uri() abort
    let l:path = TernaryIfLinux(expand('%:p'), substitute(expand('%:p'), '\\', '/', 'g')) 
    if l:path ==# ''
        return ''
    endif
    return TernaryIfLinux('file://' . l:path, 'file:///' . l:path)
endfunction

function! s:lsp_handle_definition(channel, msg) abort
    if has_key(a:msg, 'result') && !empty(a:msg.result)
        let l:target = a:msg.result[0]
        let l:file = substitute(l:target.uri, '^'.TernaryIfLinux('file://', 'file:///'), '', '')
        let l:line = l:target.range.start.line + 1
        let l:col  = l:target.range.start.character + 1
        execute 'edit +' . l:line . ' ' . fnameescape(l:file)
        call cursor(l:line, l:col)
    else
        echom "No definition found"
    endif
endfunction

function BufVarExists(bufnr, varname) abort
    let l:val = getbufvar(a:bufnr, a:varname, v:null)
    return l:val isnot v:null
endfunction

function BufVarDictSet(bufnr, varname, key, value) abort
    let buf_dict = getbufvar(a:bufnr, a:varname, {})

    if type(buf_dict) != type({})
        echohl WarningMsg
        echom 'Buffer variable '.a:varname.' is not a dictionary'
        echohl None
        return
    endif

    let buf_dict[a:key] = a:value

    call setbufvar(a:bufnr, a:varname, buf_dict)
endfunction

function s:generate_sign_cache_key(diag)
    let l:props = s:get_diagnostic_props_from_severity(a:diag.severity)
    let l:line = a:diag.range.end.line+1
    return 'line='. l:line .' name='.l:props.sign_name
endfunction

function s:generate_virtual_text_cache_key(diag)
    let l:props = s:get_diagnostic_props_from_severity(a:diag.severity)
    let l:line = a:diag.range.end.line + 1
    return 'line' . l:line .'type' . l:props.prop_type . 'text' . l:props.sign_text . " " . a:diag.message
endfunction

function! s:get_diagnostic_props_from_severity(sev) abort
    if a:sev == 1
        return {
            \ 'sign_text': 'E',
            \ 'hl_group': 'Error',
            \ 'sign_name': 'LspDiagError',
            \ 'prop_type': 'vim_lsp_virtual_text_error'
        \ }
    endif
    if a:sev == 2
        return {
            \ 'sign_text': 'W',
            \ 'hl_group': 'WarningMsg',
            \ 'sign_name': 'LspDiagWarning',
            \ 'prop_type': 'vim_lsp_virtual_text_warning'
        \ }
    endif
    return {
        \ 'sign_text': 'I',
        \ 'hl_group': 'Todo',
        \ 'sign_name': 'LspDiagInfo',
        \ 'prop_type': 'vim_lsp_virtual_text_info'
    \ }
endfunction

function s:delete_diag_prop_cache(bufnr)
    if BufVarExists(a:bufnr, 'diag_cache_virtual_text')
        call setbufvar(a:bufnr, "diag_cache_virtual_text", {})
    endif
    if BufVarExists(a:bufnr, 'diag_cache_sign')
        call setbufvar(a:bufnr, "diag_cache_sign", {}) 
    endif
endfunction
function! ClearAllDiagnostics(buf)

    let l:buf = a:buf
    let l:diag_cache_sign = getbufvar(l:buf, "diag_cache_sign")
    for key in keys(l:diag_cache_sign)
        execute 'sign unplace '. l:diag_cache_sign[key].' buffer='.l:buf
    endfor


    let l:diag_cache_virtual_text = getbufvar(l:buf, "diag_cache_virtual_text")
    for key in keys(l:diag_cache_virtual_text)
        call prop_remove({'id': l:diag_cache_virtual_text[key], 'bufnr': l:buf})
    endfor

    " execute 'sign unplace * buffer=' . a:buf

    " if exists('g:vim_lsp_virtual_text_type_defined')
    "     for l:type in [
    "         \ 'vim_lsp_virtual_text_error',
    "         \ 'vim_lsp_virtual_text_warning',
    "         \ 'vim_lsp_virtual_text_info'
    "     \ ]
    "         call prop_remove({'all': v:true, 'type': l:type, 'bufnr': a:buf})
    "     endfor
    " endif
endfunction
function! ClearExpiredDiagnostics(bufnr, diagnostics) abort
    let l:buf = a:bufnr
    if !BufVarExists(l:buf, 'diag_cache_virtual_text')
        call setbufvar(l:buf, "diag_cache_virtual_text", {})
    endif
    if !BufVarExists(l:buf, 'diag_cache_sign')
        call setbufvar(l:buf, "diag_cache_sign", {})
    endif
    call ProfileStart('ClearExpiredDiagnostics')

    let l:new_diag_sign = {} 
    let l:new_diag_virt = {} 
    for diag in a:diagnostics
        let l:cache_sign_key = s:generate_sign_cache_key(diag)
        let l:cache_virtual_text_key = s:generate_virtual_text_cache_key(diag)
        let l:new_diag_sign[l:cache_sign_key] = 1
        let l:new_diag_virt[l:cache_virtual_text_key] = 1
    endfor

    let l:diag_cache_sign = getbufvar(l:buf, "diag_cache_sign")
    for key in keys(l:diag_cache_sign)
        if !has_key(l:new_diag_sign, key)
            execute 'sign unplace '. l:diag_cache_sign[key].' buffer='.l:buf
        endif
    endfor


    let l:diag_cache_virtual_text = getbufvar(l:buf, "diag_cache_virtual_text")
    for key in keys(l:diag_cache_virtual_text)
        if !has_key(l:new_diag_virt, key)
            call prop_remove({'id': l:diag_cache_virtual_text[key], 'bufnr': l:buf})
        endif
    endfor
    

    call ProfileEnd('ClearExpiredDiagnostics')
endfunction


if !exists('g:vim_lsp_virtual_text_type_defined')
    call prop_type_add('vim_lsp_virtual_text_error', {
        \ 'highlight': 'Error',
        \ 'combine': 1,
        \ 'priority': 10,
        \ 'display': 'right_align'
    \ })
    call prop_type_add('vim_lsp_virtual_text_warning', {
        \ 'highlight': 'WarningMsg',
        \ 'combine': 1,
        \ 'priority': 10,
        \ 'display': 'right_align'
    \ })
    call prop_type_add('vim_lsp_virtual_text_info', {
        \ 'highlight': 'Todo',
        \ 'combine': 1,
        \ 'priority': 10,
        \ 'display': 'right_align'
    \ })
    let g:vim_lsp_virtual_text_type_defined = 1
endif

function! ShowDiagnostic(bufnr, diag) abort

    
    call ProfileStart('ShowDiagnostic')
    if type(a:diag) != type({})
        echoerr "ShowDiagnostic expects a dictionary"
        call ProfileEnd('ShowDiagnostic')
        return
    endif

    let l:buf       = a:bufnr
    let l:end_line  = a:diag.range.end.line + 1
    let l:msg       = a:diag.message
    let l:sev       = a:diag.severity


    let l:diag_props = s:get_diagnostic_props_from_severity(l:sev)
    let l:sign_text = l:diag_props.sign_text
    let l:hl_group  = l:diag_props.hl_group 
    let l:sign_name = l:diag_props.sign_name
    let l:prop_type = l:diag_props.prop_type

    if !exists('g:lsp_diag_signs_defined')
        execute 'sign define LspDiagError   text=E texthl=Error'
        execute 'sign define LspDiagWarning text=W texthl=WarningMsg'
        execute 'sign define LspDiagInfo    text=I texthl=Todo'
        let g:lsp_diag_signs_defined = 1
    endif


    let l:cache_sign_key = s:generate_sign_cache_key(a:diag)

    if !has_key(getbufvar(l:buf, "diag_cache_sign"), l:cache_sign_key)
        execute 'sign place '.l:end_line.' line='.l:end_line.' name='.l:sign_name.' buffer='.l:buf
        call BufVarDictSet(l:buf, "diag_cache_sign", l:cache_sign_key, l:end_line)
    endif

    if !exists('g:lsp_diag_virtual_text_align')
        let g:lsp_diag_virtual_text_align = 'after'
    endif
    if !exists('g:lsp_diag_virtual_text_padding_left')
        let g:lsp_diag_virtual_text_padding_left = 2
    endif
    if !exists('g:lsp_diag_virtual_text_wrap')
        let g:lsp_diag_virtual_text_wrap = 'wrap'
    endif


    let l:cache_virtual_text_key = s:generate_virtual_text_cache_key(a:diag)
    if !has_key(getbufvar(l:buf, "diag_cache_virtual_text"), l:cache_virtual_text_key)

        if bufloaded(l:buf)
            let l:prop_id = prop_add(
                \ l:end_line, 0,
                \ {
                \   'type': l:prop_type,
                \   'text': l:sign_text . " " . l:msg,
                \   'bufnr': l:buf,
                \   'text_align': g:lsp_diag_virtual_text_align,
                \   'text_padding_left': g:lsp_diag_virtual_text_padding_left,
                \   'text_wrap': g:lsp_diag_virtual_text_wrap
                \ })
            call BufVarDictSet(l:buf, "diag_cache_virtual_text", l:cache_virtual_text_key, l:prop_id)
        endif
    endif
    call ProfileEnd('ShowDiagnostic')
endfunction

function! s:on_lsp_msg(channel, msg) abort
    if type(a:msg) != 4 " skip non-dict messages
        " echom "skipping (non-dict)"
        return
    endif
    call s:handle_msg(a:channel, a:msg)
endfunction

function s:render_cached_diagnostics()
    let l:found_missing = 0
    let l:current_bufnr = bufnr('%')

    if BufVarExists(l:current_bufnr, "diag_cache_virtual_text")

        let l:result_errors = prop_find({"bufnr": l:current_bufnr, "type": "vim_lsp_virtual_text_warning"}) 
        let l:result_warnings = prop_find({"bufnr": l:current_bufnr, "type":  "vim_lsp_virtual_text_warning"}) 
        let l:result_info = prop_find({"bufnr": l:current_bufnr, "type": "vim_lsp_virtual_text_info"}) 
        if !empty(l:result_errors) || !empty(l:result_warnings) || !empty(l:result_info) 
            return
        endif
    endif

    if !BufVarExists(l:current_bufnr, 'diagnostics_cache')
        return
    endif
    call ClearAllDiagnostics(l:current_bufnr)
    call s:delete_diag_prop_cache(l:current_bufnr)
    for d in getbufvar(l:current_bufnr, "diagnostics_cache")
        call ShowDiagnostic(l:current_bufnr, d)
    endfor


endfunction

function! s:handle_msg(channel, msg) abort
    if has_key(a:msg, 'method') && a:msg.method ==# 'textDocument/publishDiagnostics'

        let l:filename = substitute(a:msg.params.uri, '^'. TernaryIfLinux('file://', 'file:///'), '', '')
        let l:bufnr = bufnr(l:filename)

        if l:bufnr == -1
            return
        endif
        let l:diagnostics = a:msg.params.diagnostics

        call setbufvar(l:bufnr, "diagnostics_cache", l:diagnostics)
        call ClearExpiredDiagnostics(l:bufnr, l:diagnostics)

        for d in l:diagnostics
            call ShowDiagnostic(l:bufnr, d)
        endfor
    endif
endfunction

function! s:on_lsp_exit(channel, ...) abort
    echom 'clangd exited'
    if a:0 > 0
        echom 'msg: ' . string(a:1)
    endif
endfunction

function! s:lsp_handle_references(channel, msg) abort
    if has_key(a:msg, 'result') && !empty(a:msg.result)
        new
        setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
        call setline(1, ['References:'])
        for ref in a:msg.result
            let l:file = substitute(ref.uri, '^'.TernaryIfLinux('file://', 'file:///'), '', '')
            let l:line = ref.range.start.line + 1
            let l:col  = ref.range.start.character + 1
            call append('$', l:file . ':' . l:line . ':' . l:col)
        endfor
        normal! gg
    else
        echom "No references found"
    endif
endfunction


function! LSPGoToDefintion() abort
    let l:msg = {
    \ 'jsonrpc': '2.0',
    \ 'id': 2,
    \ 'method': 'textDocument/definition',
    \ 'params': {
    \   'textDocument': {'uri': s:lsp_text_document_uri()},
    \   'position': s:lsp_position()
    \ }
    \ }
    call ch_sendexpr(g:lsp_job, l:msg, {'callback': function('s:lsp_handle_definition')})
endfunction

function! LSPReferences() abort
    let l:msg = {
    \ 'jsonrpc': '2.0',
    \ 'id': 3,
    \ 'method': 'textDocument/references',
    \ 'params': {
    \   'textDocument': {'uri': s:lsp_text_document_uri()},
    \   'position': s:lsp_position(),
    \   'context': {'includeDeclaration': v:true}
    \ }
    \ }
    call ch_sendexpr(g:lsp_job, l:msg, {'callback': function('s:lsp_handle_references')})
endfunction

let s:opts = {
      \ 'in_mode': 'lsp',
      \ 'out_mode': 'lsp',
      \ 'err_mode': 'nl',
      \ 'out_cb': function('s:on_lsp_msg'),
      \ 'err_cb': function('s:on_lsp_msg'),
      \ 'close_cb': function('s:on_lsp_exit')
      \ }

function! s:lsp_did_open() abort

    echom "opened" . " actual buffer: (" . bufnr("%") . ") " . bufname(bufnr("%"))
    if !exists('g:lsp_job')
        echom "No g:lsp_job"
        return
    endif

    let l:doc_uri = s:lsp_text_document_uri()
    if l:doc_uri ==# ''
        echom "uri empty"
        return
    endif
    let lsp_msg = {
          \ 'jsonrpc': '2.0',
          \ 'method': 'textDocument/didOpen',
          \ 'params': {
          \     'textDocument': {
          \         'uri': l:doc_uri,
          \         'languageId': 'cpp',
          \         'version': 1,
          \         'text': join(getbufline('%', 1, '$'), "\n")
          \     }
          \ }
          \ }
    call ch_sendexpr(g:lsp_job, lsp_msg)
    let b:lsp_opened = 1
endfunction

function! s:lsp_did_change() abort
    call ProfileStart('lsp_did_change')
    if !exists('g:lsp_job')
        echom "No g:lsp_job"
        call ProfileEnd('lsp_did_change')
        return
    endif
    if !exists('s:lsp_version') 
        let s:lsp_version = 1 
    else 
        let s:lsp_version += 1 
    endif


    let l:doc_uri = s:lsp_text_document_uri()
    if l:doc_uri ==# ''
        echom "uri empty"
        call ProfileEnd('lsp_did_change')
        return
    endif
    let lsp_msg = {
          \ 'jsonrpc': '2.0',
          \ 'method': 'textDocument/didChange',
          \ 'params': {
          \     'textDocument': {
          \         'uri': l:doc_uri,
          \         'version': s:lsp_version
          \     },
          \     'contentChanges': [
          \         {'text': join(getbufline('%', 1, '$'), "\n")}
          \     ]
          \ }
          \ }
     call ch_sendexpr(g:lsp_job, lsp_msg)
    call ProfileEnd('lsp_did_change')
endfunction

function! s:lsp_did_close() abort
    if !exists('b:lsp_opened') || !b:lsp_opened
        return
    endif

    let lsp_msg = {
          \ 'jsonrpc': '2.0',
          \ 'method': 'textDocument/didClose',
          \ 'params': {
          \     'textDocument': { 'uri': s:lsp_text_document_uri() }
          \ }
          \ }

    call ch_sendexpr(g:lsp_job, lsp_msg)

    unlet b:lsp_opened
endfunction


if executable('clangd')
    let g:lsp_job = job_start(['clangd', '--compile-commands-dir=build'], s:opts)
    call ch_sendexpr(g:lsp_job, {
        \ 'jsonrpc': '2.0',
        \ 'id': 1,
        \ 'method': 'initialize',
        \ 'params': {
        \     'capabilities': {},
        \     'rootUri': 'file://' . getcwd()
        \ }
    \ })

    " autocmd BufWipeout * call s:lsp_did_close()

    augroup MyLSP
      autocmd!
      for pat in g:lsp_file_patterns
        execute 'autocmd BufReadPost,BufNewFile ' . pat . ' call s:lsp_did_open()'
        execute 'autocmd TextChanged,TextChangedI ' . pat . ' call s:lsp_did_change()'
        execute 'autocmd BufEnter ' . pat . ' call s:render_cached_diagnostics()'
      endfor
    augroup END

    nnoremap gd :call LSPGoToDefintion()<CR>
    nnoremap gr :call LSPReferences()<CR>
    nnoremap K :call LSPHover()<CR>
endif
