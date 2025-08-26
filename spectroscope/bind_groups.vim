let s:config_path = split(&runtimepath, ',')[0]

execute 'source' s:config_path . '/files_utils.vim'

let g:spectroscope_files_binds = {
    \'<CR>': 'OpenFile', 
    \'<CR>v': 'OpenFileVSplitRight',
    \'<CR>h': 'OpenFileInWindowInDirectionH',
    \'<CR>j': 'OpenFileInWindowInDirectionJ',
    \'<CR>k': 'OpenFileInWindowInDirectionK',
    \'<CR>l': 'OpenFileInWindowInDirectionL',
    \'<C-o>': 'OpenFileExternally'
    \ }
