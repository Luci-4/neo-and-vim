let s:config_path = split(&runtimepath, ',')[0]

execute 'source' s:config_path . '/files_utils.vim'
execute 'source' s:config_path . '/spectroscope/files_utils.vim'
execute 'source' s:config_path . '/spectroscope/grep_utils.vim'
execute 'source' s:config_path . '/spectroscope/diagnostics_utils.vim'
execute 'source' s:config_path . '/spectroscope/buffers_utils.vim'
execute 'source' s:config_path . '/commands.vim'
execute 'source' s:config_path . '/terminal.vim'

function! MoveDown(...)
    normal! j
endfunction

function! MoveUp(...)
    normal! k
endfunction

let g:spectroscope_files_binds = {
            \'<CR>': 'OpenFileGeneric', 
            \'<C-v>': 'OpenFileVSplitRight',
            \'<C-h>': 'OpenFileInWindowInDirectionH',
            \'<C-j>': 'OpenFileInWindowInDirectionJ',
            \'<C-k>': 'OpenFileInWindowInDirectionK',
            \'<C-l>': 'OpenFileInWindowInDirectionL',
            \'<C-o>': 'OpenFileExternally',
            \ }

let g:spectroscope_grep_binds = {
            \'<CR>': 'OpenFileFromGrepStringGeneric', 
            \'<C-v>': 'OpenFileFromGrepStringVSplitRight',
            \'<C-h>': 'OpenFileFromGrepStringInDirectionH',
            \'<C-j>': 'OpenFileFromGrepStringInDirectionJ',
            \'<C-k>': 'OpenFileFromGrepStringInDirectionK',
            \'<C-l>': 'OpenFileFromGrepStringInDirectionL',
            \ }

let g:spectroscope_references_binds = {
            \'<CR>': 'OpenFileFromGrepStringGeneric', 
            \'<C-v>': 'OpenFileFromGrepStringVSplitRight',
            \'<C-h>': 'OpenFileFromGrepStringInDirectionH',
            \'<C-j>': 'OpenFileFromGrepStringInDirectionJ',
            \'<C-k>': 'OpenFileFromGrepStringInDirectionK',
            \'<C-l>': 'OpenFileFromGrepStringInDirectionL',
            \ }

let g:spectroscope_diagnostics_binds = {
            \'<CR>': 'OpenFileFromDiagnosticGeneric', 
            \'<C-v>': 'OpenFileFromDiagnosticVSplitRight',
            \'<C-h>': 'OpenFileFromDiagnosticInDirectionH',
            \'<C-j>': 'OpenFileFromDiagnosticInDirectionJ',
            \'<C-k>': 'OpenFileFromDiagnosticInDirectionK',
            \'<C-l>': 'OpenFileFromDiagnosticInDirectionL',
            \ }

let g:spectroscope_term_commands_binds = {
            \'<CR>': 'RunTermCommand', 
            \ }

let g:spectroscope_terminal_binds = {
            \'<CR>': 'OpenTerminal', 
            \ }

let g:spectroscope_buffers_binds = {
        \'<CR>': 'OpenBuffer', 
        \'<C-v>': 'OpenBufferVSplitRight',
        \'<C-h>': 'OpenBufferInWindowInDirectionH',
        \'<C-j>': 'OpenBufferInWindowInDirectionJ',
        \'<C-k>': 'OpenBufferInWindowInDirectionK',
        \'<C-l>': 'OpenBufferInWindowInDirectionL',
        \'<C-o>': 'OpenBufferExternally',
        \ }
