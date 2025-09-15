let s:config_path = split(&runtimepath, ',')[0]
execute 'source' s:config_path . '/system_check.vim'
let g:lsp_file_patterns = ['*.c', '*.cpp', '*.cc', '*.h', '*.hpp']

let g:files_project_graph = {}
let g:breadcrumbs = "__"

let s:pending_symbols = []

function! FormatSymbolForBreadcrumbs(name, kind) abort
    " Namespace
    if a:kind == 3
        if a:name ==# '(anonymous namespace)'
            let display = '{} namespace'
        else
            let display = '{} ' . a:name
        endif

        " Class
    elseif a:kind == 5
        let display = 'Cls ' . a:name

        " Struct
    elseif a:kind == 23
        let display = 'Str ' . a:name

        " Method
    elseif a:kind == 6
        let display = '∙ƒ ' . a:name

        " Function
    elseif a:kind == 12
        let display = 'ƒ ' . a:name

        " Property / Field
    elseif a:kind == 7 || a:kind == 8
        let display = '∙' . a:name

        " Constructor
    elseif a:kind == 9
        let display = '∙ƒ! ' . a:name

        " Enum
    elseif a:kind == 10
        let display = '∈ ' . a:name

        " EnumMember
    elseif a:kind == 22
        let display = '∙' . a:name

        " Constant / Macro
    elseif a:kind == 14
        let display = '≡ ' . a:name

        " Variable
    elseif a:kind == 13
        let display = 'var ' . a:name

        " Default fallback
    else
        let display = a:name
    endif

    return display
endfunction

function! s:project_graph_process_next_symbol_references(uri)
    if empty(s:pending_symbols)
        echom g:files_project_graph
        return 
    endif
    let sym = remove(s:pending_symbols, 0)
    let l:line = sym.selectionRange.start.line
    let l:col  = sym.selectionRange.start.character
    let l:msg = {
                \ 'jsonrpc': '2.0',
                \ 'id': 3,
                \ 'method': 'textDocument/references',
                \ 'params': {
                \   'textDocument': {'uri': a:uri},
                \   'position': {'line': l:line, 'character': l:col},
                \   'context': {'includeDeclaration': v:false}
                \ }
                \ }
    call ch_sendexpr(g:lsp_job, l:msg, {'callback': function('s:project_graph_handle_references', [a:uri, sym])})
endfunction

function! s:project_graph_handle_references(uri, sym, channel, msg)

    let l:sym = a:sym 
    let l:sym["references"] = []
    if has_key(a:msg, 'result') && !empty(a:msg.result)
        for ref in a:msg.result
            " let l:file = substitute(ref.uri, '^'.TernaryIfLinux('file://', 'file:///'), '', '')
            call add(l:sym["references"], ref)
            " let l:line = ref.range.start.line + 1
            " let l:col  = ref.range.start.character + 1
        endfor

        call add(g:files_project_graph[a:uri]['symbols_and_references'], sym)
    else
        echom "        No references found"
    endif
    call s:project_graph_process_next_symbol_references(a:uri)
endfunction

function! s:project_graph_add_references(uri)
    call s:project_graph_process_next_symbol_references(a:uri)
endfunction

function! s:project_graph_handle_document_symbols(uri, channel, msg)
    if has_key(a:msg, 'result') && !empty(a:msg.result)
        for sym in a:msg.result
            call add(s:pending_symbols, sym)
        endfor
        call s:project_graph_add_references(a:uri)
    else
        echom "No document symbols found"
    endif
endfunction

function! s:init_partial_graph_table_for_uri(uri)
    let g:files_project_graph[a:uri] = {
                \'symbols_and_references': [],
                \'used': {}
                \}
endfunction

function! ShowPartialProjectGraph()
    let l:uri = s:lsp_text_document_uri()
    let l:msg = {
                \ 'jsonrpc': '2.0',
                \ 'id': 5,
                \ 'method': 'textDocument/documentSymbol',
                \ 'params': {
                \   'textDocument': {'uri': l:uri}
                \ }
                \ }
    call s:init_partial_graph_table_for_uri(l:uri)
    call ch_sendexpr(g:lsp_job, l:msg, {'callback': function('s:project_graph_handle_document_symbols', [l:uri])})
endfunction

function! s:compose_scope(sym, scope, pos)
    let l:scope = a:scope
    let l:pos = a:pos
    if has_key(a:sym, 'children')  
        for el in a:sym.children
            let l:start = el.range.start
            let l:end = el.range.end
            if l:pos.line < l:start.line || l:pos.line > l:end.line
                continue
            endif
            if l:pos.line == l:start.line && l:pos.character < l:start.character
                continue
            endif
            if l:pos.line == l:end.line && l:pos.character > l:end.character
                continue
            endif
            call add(l:scope, el)
            return s:compose_scope(el, l:scope, l:pos)
            break
        endfor
    endif

    return l:scope
endfunction

function! s:find_immediate_scope(uri, channel, msg)
    let l:pos = s:lsp_position()
    if has_key(a:msg, 'result') && !empty(a:msg.result)
        let l:scope = []
        for sym in a:msg.result
            let l:start = sym.range.start
            let l:end = sym.range.end
            if l:pos.line < l:start.line || l:pos.line > l:end.line
                continue
            endif
            if l:pos.line == l:start.line && l:pos.character < l:start.character
                continue
            endif
            if l:pos.line == l:end.line && l:pos.character > l:end.character
                continue
            endif
        endfor
    else
        echom "No document symbols found"
    endif

endfunction

function! FindImmediateScope()
    let l:uri = s:lsp_text_document_uri()
    let l:msg = {
                \ 'jsonrpc': '2.0',
                \ 'id': 5,
                \ 'method': 'textDocument/documentSymbol',
                \ 'params': {
                \   'textDocument': {'uri': l:uri}
                \ }
                \ }
    call ch_sendexpr(g:lsp_job, l:msg, {'callback': function('s:find_immediate_scope', [l:uri])})
endfunction


" Set statusline to call the function
function! s:update_statusline_with_scope(uri, channel, msg)
    let l:pos = s:lsp_position()
    let l:scope = []
    if has_key(a:msg, 'result') && !empty(a:msg.result)
        for sym in a:msg.result
            let l:start = sym.range.start
            let l:end = sym.range.end
            if l:pos.line < l:start.line || l:pos.line > l:end.line
                continue
            endif
            if l:pos.line == l:start.line && l:pos.character < l:start.character
                continue
            endif
            if l:pos.line == l:end.line && l:pos.character > l:end.character
                continue
            endif
            call add(l:scope, sym)


            let l:final_scope = s:compose_scope(sym, l:scope, l:pos) 
            " let g:breadcrumbs = join(map(copy(l:final_scope), 'v:val.name'), '>')
            let g:breadcrumbs = join(map(copy(l:final_scope), 'FormatSymbolForBreadcrumbs(v:val.name, v:val.kind)'), ' > ')

            set statusline=%f\ %y\ %{g:breadcrumbs}\ %=Ln:%l\ Col:%c

            break
        endfor
    endif
endfunction

function! UpdateStatuslineWithScope()
    let l:uri = s:lsp_text_document_uri()
    let l:msg = {
                \ 'jsonrpc': '2.0',
                \ 'id': 5,
                \ 'method': 'textDocument/documentSymbol',
                \ 'params': {
                \   'textDocument': {'uri': l:uri}
                \ }
                \ }
    call ch_sendexpr(g:lsp_job, l:msg, {'callback': function('s:update_statusline_with_scope', [l:uri])})
endfunction

function! s:lsp_handle_document_symbols(channel, msg) abort
    if has_key(a:msg, 'result') && !empty(a:msg.result)
        new
        setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
        call setline(1, ['Document Symbols:'])
        for sym in a:msg.result
            let l:name = get(sym, 'name', '')
            let l:kind = get(sym, 'kind', '')
            let l:line = sym.selectionRange.start.line + 1
            let l:col  = sym.selectionRange.start.character + 1
            call append('$', l:name . ' [' . l:kind . '] ' . ':' . l:line . ':' . l:col)
        endfor
        normal! gg
    else
        echom "No document symbols found"
    endif
endfunction

function! LSPDocumentSymbols() abort
    let l:msg = {
                \ 'jsonrpc': '2.0',
                \ 'id': 5,
                \ 'method': 'textDocument/documentSymbol',
                \ 'params': {
                \   'textDocument': {'uri': s:lsp_text_document_uri()}
                \ }
                \ }
    call ch_sendexpr(g:lsp_job, l:msg, {'callback': function('s:lsp_handle_document_symbols')})
endfunction

function! LSPHover() abort
    " echom  {'textDocument': {'uri': s:lsp_text_document_uri()}, 'position': s:lsp_position()}
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
    if has_key(a:msg, 'result') && type(a:msg.result) == type({}) && has_key(a:msg.result, 'contents')
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
                    \ 'hl_group': 'WarnMsg',
                    \ 'sign_name': 'LspDiagWarning',
                    \ 'prop_type': 'vim_lsp_virtual_text_warning'
                    \ }
    endif
    return {
                \ 'sign_text': 'I',
                \ 'hl_group': 'InfoMsg',
                \ 'sign_name': 'LspDiagInfo',
                \ 'prop_type': 'vim_lsp_virtual_text_info'
                \ }
endfunction


function! ClearAllDiagnostics(buf)
    let l:buf = a:buf
    execute 'sign unplace * buffer=' . l:buf
    call prop_remove({'types': [ 'vim_lsp_virtual_text_error', 'vim_lsp_virtual_text_warning',  'vim_lsp_virtual_text_info'], 'bufnr': l:buf})
endfunction


if !exists('g:vim_lsp_virtual_text_type_defined')
    call prop_type_add('vim_lsp_virtual_text_error', {
                \ 'highlight': 'Error',
                \ 'combine': 1,
                \ 'priority': 10,
                \ 'display': 'right_align'
                \ })
    call prop_type_add('vim_lsp_virtual_text_warning', {
                \ 'highlight': 'WarnMsg',
                \ 'combine': 1,
                \ 'priority': 10,
                \ 'display': 'right_align'
                \ })
    call prop_type_add('vim_lsp_virtual_text_info', {
                \ 'highlight': 'InfoMsg',
                \ 'combine': 1,
                \ 'priority': 10,
                \ 'display': 'right_align'
                \ })
    let g:vim_lsp_virtual_text_type_defined = 1
endif

function! ShowDiagnostic(bufnr, diag) abort
    if type(a:diag) != type({})
        echoerr "ShowDiagnostic expects a dictionary"
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
        execute 'sign define LspDiagWarning text=W texthl=WarnMsg'
        execute 'sign define LspDiagInfo    text=I texthl=InfoMsg'
        let g:lsp_diag_signs_defined = 1
    endif
    execute 'sign place '.l:end_line.' line='.l:end_line.' name='.l:sign_name.' buffer='.l:buf
    if !exists('g:lsp_diag_virtual_text_align')
        let g:lsp_diag_virtual_text_align = 'after'
    endif
    if !exists('g:lsp_diag_virtual_text_padding_left')
        let g:lsp_diag_virtual_text_padding_left = 2
    endif
    if !exists('g:lsp_diag_virtual_text_wrap')
        let g:lsp_diag_virtual_text_wrap = 'wrap'
    endif

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

        if type(getbufvar(l:buf, 'diagnostics', -1)) != type([])
            call setbufvar(l:buf, 'diagnostics', [])
        endif
    endif
endfunction

function! s:on_lsp_msg(channel, msg) abort
    if type(a:msg) != 4 
        return
    endif
    call s:handle_msg(a:channel, a:msg)
endfunction

function s:render_cached_diagnostics()
    let l:current_bufnr = bufnr('%')

    call ClearAllDiagnostics(l:current_bufnr)
    let l:old_diags = getbufvar(l:current_bufnr, "diagnostics", []) 
    for d in l:old_diags 
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
        for diag in l:diagnostics
            let diag.filename = l:filename
        endfor

        call ClearAllDiagnostics(l:bufnr)


        for d in l:diagnostics
            call ShowDiagnostic(l:bufnr, d)
        endfor
        call setbufvar(l:bufnr, 'diagnostics', l:diagnostics) 
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
        let l:formatted = []
        echom a:msg.result
        for ref in a:msg.result
            let l:file = substitute(ref.uri, '^'.TernaryIfLinux('file://', 'file:///'), '', '')

            let l:file = fnamemodify(l:file, ":.")
            let l:line = ref.range.start.line + 1
            let l:col  = ref.range.start.character + 1
            if filereadable(l:file)
                let l:lines = readfile(l:file)
                if l:line <= len(l:lines)
                    let l:text = l:lines[l:line - 1]
                else
                    let l:text = ''
                endif
            else
                let l:text = ''
            endif
            call add(l:formatted, l:file . ':' . l:line . ':' . l:col . ':' . l:text)
        endfor
        call OpenSpecialListBuffer(l:formatted, g:spectroscope_binds_reference_directions, 'referenceslist', 1, 0)
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

function! FormatDiagnosticForList(diag)
    let l:filepath = a:diag.filename
    let l:end_line  = a:diag.range.end.line + 1
    let l:msg       = a:diag.message
    let l:sev       = a:diag.severity

    let l:diag_props = s:get_diagnostic_props_from_severity(l:sev)
    let l:sign_text = l:diag_props.sign_text
    let l:hl_group  = l:diag_props.hl_group 
    let l:sign_name = l:diag_props.sign_name
    let l:prop_type = l:diag_props.prop_type
    let relpath = fnamemodify(l:filepath, ':.')
    return l:sign_text . ' ' . l:msg . ' : ' . relpath . ':' . l:end_line  
endfunction

function! LSPDiagnosticsForBuffer()
    let l:current_bufnr = bufnr('%')
    let l:old_diags = getbufvar(l:current_bufnr, "diagnostics", []) 
    call OpenSpecialListBuffer(l:old_diags, g:spectroscope_binds_diagnostics_directions, 'diagnosticslist', 1, 0, 'FormatDiagnosticForList')
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
    echom l:msg
    call ch_sendexpr(g:lsp_job, l:msg, {'callback': function('s:lsp_handle_references')})
endfunction

function! LSPComplete() abort
    echom s:lsp_position()
    let l:msg = {
                \ 'jsonrpc': '2.0',
                \ 'id': 5,
                \ 'method': 'textDocument/completion',
                \ 'params': {
                \   'textDocument': {'uri': s:lsp_text_document_uri()},
                \   'position': s:lsp_position()
                \ }
                \ }
    call ch_sendexpr(g:lsp_job, l:msg, {'callback': function('s:lsp_handle_completion')})
endfunction

function! s:lsp_handle_completion(channel, msg) abort
    if has_key(a:msg, 'error')
        echoerr a:msg.error.message
        return
    endif

    if !has_key(a:msg, 'result') || empty(a:msg.result)
        return
    endif

    let l:items = a:msg.result
    " LSP spec: result can be {items: [...], isIncomplete: v:true} or just [...]
    if type(l:items) == type({})
        let l:items = l:items.items
    endif

    " let l:completions = map(l:items, 'get(v:val, "label", "")')

    call CustomComplete(l:items)
endfunction

function! CustomComplete(lsp_items)
    let prefix = matchstr(getline('.'), '\k*$')

    if prefix ==# ''
        return ''
    endif
    if empty(a:lsp_items)
        return "\<C-n>"
    endif

    let start = col('.') - 1

    let items = []
    for item in a:lsp_items
        if has_key(item, 'textEdit')
            let edit = item.textEdit
            let start = edit.range.start.character + 1
            call add(items, edit.newText)
        elseif has_key(item, 'insertText')
            call add(items, item.insertText)
        else
            call add(items, item.label)
        endif
    endfor

    " Call Vim's completion
    call complete(start, items)
    return ''
endfunction

function! s:lsp_token_type_to_hl(type, mods) abort
    "0 namespace
    "1 type
    "2 class
    "3 enum
    "4 interface
    "5 struct
    "6 typeParameter
    "7 parameter
    "8 variable
    "9 property
    "10 enumMember
    "11 event
    "12 function
    "13 method
    "14 macro
    "15 keyword
    "16 modifier
    "17 comment
    "18 string
    "19 number
    "20 regexp
    "21 operator

    let l:map = {
        \ 0:  'Identifier',   
        \ 1:  'Type',         
        \ 2:  'Type',         
        \ 3:  'Type',         
        \ 4:  'Type',         
        \ 5:  'Type',         
        \ 6:  'Type',         
        \ 7:  'Identifier',   
        \ 8:  'Identifier',   
        \ 9:  'Identifier',   
        \ 10: 'Identifier',   
        \ 11: 'Identifier',   
        \ 12: 'Function',     
        \ 13: 'Function',     
        \ 14: 'Macro',        
        \ 15: 'Keyword',      
        \ 16: 'Keyword',      
        \ 17: 'Comment',      
        \ 18: 'String',       
        \ 19: 'Number',       
        \ 20: 'String',       
        \ 21: 'Operator',     
        \ }

    return get(l:map, a:type, 'Identifier')
endfunction

function! s:lsp_handle_semantic_tokens(channel, msg) abort
    if !has_key(a:msg, 'result') || !has_key(a:msg.result, 'data')
        echom "No semantic tokens"
        return
    endif

    if exists('w:lsp_match_ids')
        for id in w:lsp_match_ids
            call matchdelete(id)
        endfor
    endif
    let w:lsp_match_ids = []

    let l:data = a:msg.result.data
    let l:line = 0
    let l:char = 0

    for i in range(0, len(l:data)-1, 5)
        let l:deltaLine = l:data[i]
        let l:deltaStart = l:data[i+1]
        let l:length = l:data[i+2]
        let l:tokenType = l:data[i+3]
        let l:tokenMods = l:data[i+4]

        let l:line += l:deltaLine
        if l:deltaLine == 0
            let l:char += l:deltaStart
        else
            let l:char = l:deltaStart
        endif

        let l:hlgroup = s:lsp_token_type_to_hl(l:tokenType, l:tokenMods)
        let id = matchaddpos(l:hlgroup, [[l:line+1, l:char+1, l:length]], g:lsp_syntax_highlights_priority)
        call add(w:lsp_match_ids, id)
    endfor
endfunction
function! LSPRequestSemanticTokens() abort
    if !get(g:, 'lsp_syntax_highlights_enabled', 1)
        return
    endif
    let l:msg = {
                \ 'jsonrpc': '2.0',
                \ 'id': 42,
                \ 'method': 'textDocument/semanticTokens/full',
                \ 'params': {
                \   'textDocument': {'uri': s:lsp_text_document_uri()}
                \ }
                \ }
    call ch_sendexpr(g:lsp_job, l:msg, {'callback': function('s:lsp_handle_semantic_tokens')})
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
    if !exists('g:lsp_job')
        echom "No g:lsp_job"
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
let g:lsp_complete_timer = -1

function! s:DebouncedLSPComplete() abort
    if g:lsp_complete_timer != -1
        call timer_stop(g:lsp_complete_timer)
    endif
    let g:lsp_complete_timer = timer_start(300, { -> execute('if !pumvisible() | call LSPComplete() | endif') })
endfunction

if executable('clangd')
    let g:lsp_job = job_start(['clangd', '--compile-commands-dir=build'], s:opts)
    call ch_sendexpr(g:lsp_job, {
                \ 'jsonrpc': '2.0',
                \ 'id': 1,
                \ 'method': 'initialize',
                \ 'params': {
                \     'capabilities': {
                \       "textDocument": {
                \           "documentSymbol": {
                \               "hierarchicalDocumentSymbolSupport": v:true
                \           },
                \        "semanticTokens": {
                \            "dynamicRegistration": v:false,
                \            "tokenTypes": [
                \                'namespace','type','class','enum','interface','struct',
                \                'function','method','property','variable','parameter',
                \                'keyword','comment','string','number','operator'
                \            ],
                \            "tokenModifiers": [
                \                'declaration','readonly','static','deprecated','abstract',
                \                'async','modification','documentation','defaultLibrary'
                \            ],
                \            "requests": {
                \                "full": v:true,
                \                "range": v:false
                \            }
                \        }
                \       }
                \       },
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
            execute 'autocmd BufEnter,CursorMoved,WinEnter,VimResized,TextChanged,TextChangedI '  . pat .  ' call UpdateStatuslineWithScope()'
            execute 'autocmd BufReadPost ' . pat . ' call LSPRequestSemanticTokens()'
            execute 'autocmd TextChangedI,TextChangedP ' . pat . ' call s:DebouncedLSPComplete()'
        endfor
    augroup END

    nnoremap gd :call LSPGoToDefintion()<CR>
    nnoremap gr :call LSPReferences()<CR>
    nnoremap K :call LSPHover()<CR>
    nnoremap ge :call LSPDiagnosticsForBuffer()<CR>
    nnoremap <leader>ds :call LSPDocumentSymbols()<CR>
    nnoremap <leader>pg :call ShowPartialProjectGraph()<CR>
    nnoremap <leader>sc :call UpdateStatuslineWithScope()<CR>
    inoremap <expr> <M-j> pumvisible() ? "\<C-n>" : "\<M-j>"
    inoremap <expr> <M-k> pumvisible() ? "\<C-p>" : "\<M-k>"
    inoremap <expr> <Esc>j pumvisible() ? "\<C-n>" : "\<M-j>"
    inoremap <expr> <Esc>k pumvisible() ? "\<C-p>" : "\<M-k>"
    inoremap <expr> <Tab> pumvisible() ? "\<C-y>" : "\<Tab>"
    highlight! link Pmenu Visual
    highlight link PmenuSel Search
endif

