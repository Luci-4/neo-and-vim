let s:config_path = split(&runtimepath, ',')[0]
execute 'source' s:config_path . './spectroscope/cached.vim'


function! AsyncCacheFiles() abort
    call timer_start(0, { -> s:GenerateFileCache() })
endfunction

function! s:GenerateFileCache() abort
    let full_paths = globpath(getcwd(), '**/*.*', 0, 1)
    let g:files_cached = map(full_paths, {_, val -> fnamemodify(val, ':.')})
    echom 'Files cached: ' . len(g:files_cached)
endfunction

call AsyncCacheFiles()
