let s:config_path = split(&runtimepath, ',')[0]
execute 'source' s:config_path . '/spectroscope/cached.vim'
execute 'source' s:config_path . '/spectroscope/blacklist_args_cache.vim'

function! GenerateFileCache() abort
    let g:files_cached = FindFilesInCWDSystemBased()
    let g:files_cached_shell_escaped = map(copy(g:files_cached), 'shellescape(v:val)')
endfunction

function! FindFilesInCWDSystemBased()
    let l:root = getcwd()
    let l:files = []

    if !empty(g:files_cached)
        return g:files_cached
    endif

    if empty(g:blacklist_args_cached_for_tools)
        call GenerateExclusionArgsForFiles()
    endif
    if executable('fd')
        let l:cmd = 'fd . --type f --hidden --follow' .
                    \ g:blacklist_args_cached_for_tools['fd'] .
                    \ ' --base-directory ' . shellescape(l:root)
        let l:files = split(system(l:cmd), "\n")
        return l:files
    endif


    let l:files = globpath(l:root, '**/*', 0, 1)
    let l:files = filter(l:files, 'isdirectory(v:val) == 0')
    if !empty(g:blacklist_directories)
        for dir in g:blacklist_directories
            let l:files = filter(l:files, 'v:val !~# "/" . dir . "/"')
        endfor
    endif

    for pattern in g:blacklist_files
        let l:files = filter(l:files, 'v:val !~# pattern_to_regex(pattern)')
    endfor

    let l:files = filter(l:files, 'v:val =~# "^" . escape(l:root, "/\\")')
    let l:files = map(l:files, 'fnamemodify(v:val, ":.")')
    return l:files
endfunction


function! OpenFileInDirection(file, direction)
    call OpenFileInDirectionAt(a:file, a:direction, 0, 0)
endfunction

function OpenFileAt(file, line, ...)
    let l:col = a:0 ? a:1 : 1
    call OpenFileInDirectionAt(a:file, '', a:line, l:col)
endfunction

function OpenFileVSplitAt(file, line, ...)
    let l:col = a:0 ? a:1 : 1
    call OpenFileInDirectionAt(a:file, 'v', a:line, l:col)
endfunction

function! OpenFileInDirectionAt(file, direction, line, col)
    if empty(a:file)
        echo "No file provided"
        return
    endif

    if !filereadable(a:file)
        echo "File does not exist: " . a:file
        return
    endif

    if !empty(a:direction)
        if a:direction ==# 'v'
            execute 'vsplit ' . fnameescape(a:file)
        else
            execute "wincmd " . a:direction
        endif
    endif
    execute "edit " . fnameescape(a:file)

    if a:line != 0 || a:col != 0
        call cursor(a:line, a:col)
    endif
endfunction

function! OpenFileGeneric(file, ...)
    if empty(a:file)
        echo "No file provided"
        return
    endif

    if !filereadable(a:file)
        echo "File does not exist: " . a:file
        return
    endif
    let l:direction = get(a:000, 0, '')   " '', 'v', 'h', etc.
    let l:line      = get(a:000, 1, 1)    " default 1
    let l:col       = get(a:000, 2, 1)    " default 1

    if l:direction ==# 'v'
        execute 'vsplit ' . fnameescape(a:file)
    else
        if l:direction ==# 'h' || l:direction ==# 'l' || l:direction ==# 'k' || l:direction ==# 'j'
            execute "wincmd " . l:direction
        endif
        execute "edit " . fnameescape(a:file)
    endif

    if l:line > 1 || l:col > 1
        call cursor(l:line, l:col)
    endif
endfunction

function! OpenFileExternally(file)
  let l:file = expand(a:file)
  if empty(l:file)
    echo "No file to open"
    return
  endif

  if has('win32') || has('win64')
    let l:cmd = 'start "" ' . shellescape(l:file)
  elseif has('macunix')
    let l:cmd = 'open ' . shellescape(l:file)
  elseif has('unix')
    let l:cmd = 'xdg-open ' . shellescape(l:file)
  else
    echo "Unsupported OS"
    return
  endif

  " Run the command silently
  call system(l:cmd)
  echo "Opened " . l:file . " externally"
endfunction
