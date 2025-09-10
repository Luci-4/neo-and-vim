let s:config_path = split(&runtimepath, ',')[0]
execute 'source' s:config_path . './spectroscope/cached.vim'
execute 'source' s:config_path . './system_check.vim'

function! AsyncCacheFiles() abort
    call timer_start(0, { -> s:GenerateFileCache() })
endfunction

function! s:GenerateFileCache() abort
    let g:files_cached = FindFilesInCWDSystemBased([])
    echom 'Files cached: ' . len(g:files_cached)
endfunction

call AsyncCacheFiles()
