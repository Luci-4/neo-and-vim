let s:config_path = expand('~/vimfiles')


" Source the config files

execute 'source' s:config_path . '/settings.vim'
execute 'source' s:config_path . '/remaps.vim'
execute 'source' s:config_path . '/lsp_stuff.vim'
" execute 'source' s:config_path . '/autocommands.vim'


" Map it to <leader>o for convenience
" nnoremap <leader>o :call OpenFileExternally()<CR>
