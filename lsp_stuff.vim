let g:lsp_diagnostics_enabled = 1
let g:lsp_use_native_client = 1
let g:lsp_virtual_text_enabled = 1 
let g:lsp_diagnostics_virtual_text_align = "after"
let g:lsp_diagnostics_virtual_text_padding_left = 2
let g:lsp_signs_enabled = 1

if executable('clangd')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'clangd',
        \ 'cmd': ['clangd'],
        \ 'allowlist': ['c', 'cpp', 'objc', 'objcpp'],
        \ })
endif

function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes
    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> gr <plug>(lsp-references)
    nmap <buffer> K <plug>(lsp-hover)
    nmap <buffer> <leader>rn <plug>(lsp-rename)
    let g:lsp_format_sync_timeout = 500
    autocmd BufWritePre *.rs,*.go call LspDocumentFormat()
endfunction

augroup lsp_install
    autocmd!
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END
