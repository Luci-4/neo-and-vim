let s:config_path = split(&runtimepath, ',')[0]
execute 'source' s:config_path . '/spectroscope/spectroscope.vim'
execute 'source' s:config_path . '/spectroscope/bind_groups.vim'

let g:files_spectroscope_file_type = 'commands'


function! ListTermCommands()
    let l:commands = map(values(g:term_commands), {_, v -> v.func()})
    if !empty(l:commands)
        call OpenSpecialListBuffer(l:commands, g:spectroscope_term_commands_binds, g:files_spectroscope_file_type, 1, 0)
    else
        echo "No files found in current directory."
    endif
endfunction
