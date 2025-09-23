let s:config_path = split(&runtimepath, ',')[0]
execute 'source' s:config_path . '/files_utils.vim'
call GenerateFileCache(0)
execute 'source' s:config_path . '/settings.vim'
execute 'source' s:config_path . '/custom_settings.vim'
execute 'source' s:config_path . '/remaps.vim'
execute 'source' s:config_path . '/markdown.vim'

if !has('nvim')
    execute 'source' s:config_path . '/git.vim'
endif

execute 'source' s:config_path . '/lsp_utils.vim'
if has('nvim')
    lua require('lsp')
endif
function! SetStatusLine()
    set statusline=%f\ %y\ %{g:breadcrumbs}\ %=Ln:%l\ Col:%c
endfunction

autocmd VimEnter * if get(g:, 'breadcrumbs', '') !=# '' | call SetStatusLine() | endif
autocmd VimEnter * call SetupSpecialListBufferPicker('filelist')
autocmd VimEnter * call SetupSpecialListBufferPicker('greplist')
command! CacheRefresh call GenerateFileCache(1)
