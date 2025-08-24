let s:config_path = split(&runtimepath, ',')[0]
execute 'source' s:config_path . '/system_check.vim'

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
    echom "running hover with"
    echom l:msg
    call ch_sendexpr(g:lsp_job, l:msg, {'callback': function('s:lsp_handle_hover')})
endfunction

function! s:lsp_handle_hover(channel, msg) abort
    echom a:msg
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
            echom "No hover info (empty lines)"
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
    return TernaryIfLinux('file://' . expand('%:p'), 'file:///' . substitute(expand('%:p'), '\\', '/', 'g'))
endfunction

function! s:lsp_handle_definition(channel, msg) abort
    echom a:msg
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

function! ShowDiagnostic(bufnr, diag) abort
    if type(a:diag) != type({})
        echoerr "ShowDiagnostic expects a dictionary"
        return
    endif

    let l:buf       = a:bufnr
    let l:end_line  = a:diag.range.end.line + 1
    let l:msg       = a:diag.message
    let l:sev       = a:diag.severity
    if l:sev == 1
        let l:sign_text = "E"
        let l:hl_group  = 'Error' 
        let l:sign_name = 'LspDiagError'
        let l:prop_type = 'vim_lsp_virtual_text_error'
    elseif l:sev == 2
        let l:hl_group  = 'WarningMsg'
        let l:sign_text = "W"
        let l:sign_name = 'LspDiagWarning'
        let l:prop_type = 'vim_lsp_virtual_text_warning'
    else
        let l:hl_group  = 'Todo'
        let l:sign_text = "I"
        let l:sign_name = 'LspDiagInfo'
        let l:prop_type = 'vim_lsp_virtual_text_info'
    endif

    if !exists('g:lsp_diag_signs_defined')
        execute 'sign define LspDiagError   text=E texthl=Error'
        execute 'sign define LspDiagWarning text=W texthl=WarningMsg'
        execute 'sign define LspDiagInfo    text=I texthl=Todo'
        let g:lsp_diag_signs_defined = 1
    endif

    execute 'sign place '.l:end_line.' line='.l:end_line.' name='.l:sign_name.' buffer='.l:buf


    echom string(l:sev) . " " . l:sign_text . " " . l:hl_group . " "  . " "  . l:msg 
    if !exists('g:lsp_diag_virtual_text_align')
        let g:lsp_diag_virtual_text_align = 'after'
    endif
    if !exists('g:lsp_diag_virtual_text_padding_left')
        let g:lsp_diag_virtual_text_padding_left = 2
    endif
    if !exists('g:lsp_diag_virtual_text_wrap')
        let g:lsp_diag_virtual_text_wrap = 'wrap'
    endif

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

    call prop_remove({'all': v:true, 'type': l:prop_type, 'bufnr': l:buf}, l:end_line)

    call prop_add(
        \ l:end_line, 0,
        \ {
        \   'type': l:prop_type,
        \   'text': l:sign_text . " " . l:msg,
        \   'bufnr': l:buf,
        \   'text_align': g:lsp_diag_virtual_text_align,
        \   'text_padding_left': g:lsp_diag_virtual_text_padding_left,
        \   'text_wrap': g:lsp_diag_virtual_text_wrap
        \ })
endfunction

function! s:on_lsp_msg(channel, msg) abort
    if type(a:msg) != 4 " skip non-dict messages
        " echom "skipping (non-dict)"
        return
    endif
    call s:handle_msg(a:channel, a:msg)
endfunction

function! s:handle_msg(channel, msg) abort
    if has_key(a:msg, 'method') && a:msg.method ==# 'textDocument/publishDiagnostics'
        let l:filename = substitute(a:msg.params.uri, '^'. TernaryIfLinux('file://', 'file:///'), '', '')
        let l:bufnr = bufnr(l:filename)
        if l:bufnr == -1
            return
        endif
        let l:diagnostics = a:msg.params.diagnostics
        echom 'Diagnostics for ' . l:filename . ': ' . string(l:diagnostics)
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
    if exists('b:lsp_opened') && b:lsp_opened
        echom "already opened; don't open again"
        return

    endif
    echom "opened" 
    if !exists('g:lsp_job')
        echom "No g:lsp_job"
        return
    endif


    let lsp_msg = {
          \ 'jsonrpc': '2.0',
          \ 'method': 'textDocument/didOpen',
          \ 'params': {
          \     'textDocument': {
          \         'uri': s:lsp_text_document_uri(),
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
    echom "changed file"
    if !exists('g:lsp_job')
        echom "No g:lsp_job"
        return
    endif
    if !exists('s:lsp_version') 
        let s:lsp_version = 1 
    else 
        let s:lsp_version += 1 
    endif
    let lsp_msg = {
          \ 'jsonrpc': '2.0',
          \ 'method': 'textDocument/didChange',
          \ 'params': {
          \     'textDocument': {
          \         'uri': s:lsp_text_document_uri(),
          \         'version': s:lsp_version
          \     },
          \     'contentChanges': [
          \         {'text': join(getbufline('%', 1, '$'), "\n")}
          \     ]
          \ }
          \ }

    call ch_sendexpr(g:lsp_job, lsp_msg)
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

    autocmd BufUnload,BufDelete * call s:lsp_did_close()

    autocmd BufReadPost,BufNewFile * call s:lsp_did_open()

    autocmd TextChanged,TextChangedI * call s:lsp_did_change()

    nnoremap gd :call LSPGoToDefintion()<CR>
    nnoremap gr :call LSPReferences()<CR>
    nnoremap K :call LSPHover()<CR>
endif
