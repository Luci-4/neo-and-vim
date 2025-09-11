let s:config_path = split(&runtimepath, ',')[0]

execute 'source' s:config_path . '/files_utils.vim'
execute 'source' s:config_path . '/spectroscope/files_utils.vim'
execute 'source' s:config_path . '/spectroscope/grep_utils.vim'

function! MoveDown(...)
    normal! j
endfunction

function! MoveUp(...)
    normal! k
endfunction

let g:spectroscope_files_binds = {
            \'<CR>': 'OpenFile', 
            \'<CR>v': 'OpenFileVSplitRight',
            \'<CR>h': 'OpenFileInWindowInDirectionH',
            \'<CR>j': 'OpenFileInWindowInDirectionJ',
            \'<CR>k': 'OpenFileInWindowInDirectionK',
            \'l<CR>': 'OpenFileInWindowInDirectionL',
            \'<C-o>': 'OpenFileExternally',
            \ }


let g:spectroscope_picker_binds_files_directions = {
            \'': 'OpenFile', 
            \'v': 'OpenFileVSplitRight',
            \'h': 'OpenFileInWindowInDirectionH',
            \'j': 'OpenFileInWindowInDirectionJ',
            \'k': 'OpenFileInWindowInDirectionK',
            \'l': 'OpenFileInWindowInDirectionL',
            \'o': 'OpenFileExternally',
            \ }

let g:spectroscope_picker_binds_grep_directions = {
            \'': 'OpenFileWhereString', 
            \'v': 'OpenFileWhereStringVSplitRight',
            \'h': 'OpenFileWhereStringInDirectionH',
            \'j': 'OpenFileWhereStringInDirectionJ',
            \'k': 'OpenFileWhereStringInDirectionK',
            \'l': 'OpenFileWhereStringInDirectionL',
            \ }
