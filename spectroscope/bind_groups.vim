let s:config_path = split(&runtimepath, ',')[0]

execute 'source' s:config_path . '/files_utils.vim'
execute 'source' s:config_path . '/spectroscope/files_utils.vim'
execute 'source' s:config_path . '/spectroscope/grep_utils.vim'
execute 'source' s:config_path . '/spectroscope/diagnostics_utils.vim'

function! MoveDown(...)
    normal! j
endfunction

function! MoveUp(...)
    normal! k
endfunction

let g:spectroscope_files_binds = {
            \'<CR>': 'OpenFileGeneric', 
            \'<C-v>': 'OpenFileVSplitRight',
            \'H': 'OpenFileInWindowInDirectionH',
            \'J': 'OpenFileInWindowInDirectionJ',
            \'K': 'OpenFileInWindowInDirectionK',
            \'L': 'OpenFileInWindowInDirectionL',
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
            \'': 'OpenFileFromGrepStringGeneric', 
            \'v': 'OpenFileFromGrepStringVSplitRight',
            \'h': 'OpenFileFromGrepStringInDirectionH',
            \'j': 'OpenFileFromGrepStringInDirectionJ',
            \'k': 'OpenFileFromGrepStringInDirectionK',
            \'l': 'OpenFileFromGrepStringInDirectionL',
            \ }

let g:spectroscope_binds_reference_directions = {
            \'<CR>': 'OpenFileFromGrepStringGeneric', 
            \'<C-v>': 'OpenFileFromGrepStringVSplitRight',
            \'H': 'OpenFileFromGrepStringInDirectionH',
            \'J': 'OpenFileFromGrepStringInDirectionJ',
            \'K': 'OpenFileFromGrepStringInDirectionK',
            \'L': 'OpenFileFromGrepStringInDirectionL',
            \ }

let g:spectroscope_binds_diagnostics_directions = {
            \'<CR>': 'OpenFileFromDiagnosticGeneric', 
            \'<C-v>': 'OpenFileFromDiagnosticVSplitRight',
            \'H': 'OpenFileFromDiagnosticInDirectionH',
            \'J': 'OpenFileFromDiagnosticInDirectionJ',
            \'K': 'OpenFileFromDiagnosticInDirectionK',
            \'L': 'OpenFileFromDiagnosticInDirectionL',
            \ }
