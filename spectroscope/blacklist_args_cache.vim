let s:config_path = split(&runtimepath, ',')[0]
execute 'source' s:config_path . '/spectroscope/cached.vim'
execute 'source' s:config_path . '/spectroscope/blacklist.vim'
execute 'source' s:config_path . '/system_check.vim'


function! GenerateExclusionArgsForFiles()
    for tool in ['fd', 'rg', 'find', 'grep']
        let g:blacklist_args_cached_for_tools[tool] = s:ExcludeArgsForFilesTool(tool, g:blacklist_files, g:blacklist_directories)
    endfor
endfunction


function! s:ExcludeArgsForFilesTool(tool, blacklist_files, blacklist_directories) abort
    let l:args = []

    for l:file in a:blacklist_files
        if a:tool ==# 'rg'
            call add(l:args, '--glob !' . shellescape(l:file))
        elseif a:tool ==# 'fd'
            call add(l:args, '--exclude ' . shellescape(l:file))
        elseif a:tool ==# 'find'
            " find uses ! -name "pattern" for exclusion
            call add(l:args, '! -name ' . shellescape(l:file))
        elseif a:tool ==# 'grep'
            call add(l:args, '--exclude=' . shellescape(l:file)) 
        endif
    endfor

    for l:dir in a:blacklist_directories
        if a:tool ==# 'rg'
            call add(l:args, '--glob !' . l:dir . '/**')
        elseif a:tool ==# 'fd'
            call add(l:args, '--exclude ' . l:dir)
        elseif a:tool ==# 'find'
            call add(l:args, '! -path ' . shellescape(l:dir) . ' ! -path ' . shellescape(l:dir . '/*'))
        elseif a:tool ==# 'grep'
            call add(l:args, '--exclude-dir=' . shellescape(l:dir))
        endif
    endfor

    return ' ' . join(l:args, ' ')
endfunction
