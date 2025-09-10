let s:config_path = split(&runtimepath, ',')[0]

execute 'source' s:config_path . '/spectroscope/spectroscope.vim'
execute 'source' s:config_path . './spectroscope/bind_groups.vim'
execute 'source' s:config_path . './spectroscope/continuous_search.vim'
execute 'source' s:config_path . './spectroscope/cached.vim'


function! ListFilesInBuffer()
    " let l:full_paths = globpath(getcwd(), '**/*.*', 0, 1)
    " let l:files = map(l:full_paths, {_, val -> fnamemodify(val, ':.' )})
    let l:files = FindFilesInCWDSystemBased(['build', ".cache", ".git"])
    call OpenSpecialListBuffer(l:files, g:spectroscope_files_binds, 'filelist', 1)
endfunction

function! TestFilesFind()
    let blacklist = ['build/*']
    echom FindFilesSystemBased(getcwd(), '**/*', blacklist)
endfunction

function! FilterList(bufnr, pattern)
    if a:pattern ==# ''
        let l:filtered = s:current_list
    else
        let l:filtered = filter(copy(s:current_list), 'v:val =~ a:pattern')
    endif

    call setbufvar(a:bufnr, '&modifiable', 1)
    call setbufline(a:bufnr, 1, l:filtered)
    call deletebufline(a:bufnr, len(l:filtered) + 1, '$')
    call setbufvar(a:bufnr, '&modifiable', 0)
endfunction

function! OpenSpecialListBufferWithSearch(list, action_map, filetype)
    let s:current_list = a:list
    let s:action_map = a:action_map
    let s:filetype = a:filetype

    vert enew
    let l:new_buf = bufnr('%')

    call setbufvar(l:new_buf, '&buftype', 'nofile')
    call setbufvar(l:new_buf, '&bufhidden', 'wipe')
    call setbufvar(l:new_buf, '&swapfile', 0)
    call setbufvar(l:new_buf, '&modifiable', 1)
    call setbufvar(l:new_buf, '&filetype', a:filetype)
    call setbufvar(l:new_buf, '&buflisted', 0)

    call setbufline(l:new_buf, 1, a:list)
    call setbufvar(l:new_buf, '&modifiable', 0)

    for [key, func] in items(a:action_map)
      execute 'nnoremap <buffer> ' . key . ' :call ' . func . '(getline("."))<CR>'
    endfor
    call ContinuousInputPopup(l:new_buf, function('FilterList'))
    
endfunction

function! FindFiles()
    let l:files = copy(g:files_cached)

    " if executable('find')
    "     try
    "         let l:files = split(system('find '.shellescape(getcwd()).' -type f'), "\n")
    "     catch
    "         let l:files = []
    "     endtry
    " endif

    if empty(l:files)
        let l:full_paths = globpath(getcwd(), '**/*.*', 0, 1)
        let l:files = map(l:full_paths, {_, val -> fnamemodify(val, ':.' )})
    endif

    if !empty(l:files)
        call OpenSpecialListBuffer(l:files, g:spectroscope_files_binds, 'filelist')
    else
        echo "No files found in current directory."
    endif
endfunction

function! FindFilesWithFilter()
    let l:files = copy(g:files_cached)

    " if executable('find')
    "     try
    "         let l:files = split(system('find '.shellescape(getcwd()).' -type f'), "\n")
    "     catch
    "         let l:files = []
    "     endtry
    " endif

    if empty(l:files)
        let l:full_paths = globpath(getcwd(), '**/*.*', 0, 1)
        let l:files = map(l:full_paths, {_, val -> fnamemodify(val, ':.' )})
    endif

    if !empty(l:files)
        call OpenSpecialListBufferPicker(l:files, g:spectroscope_picker_binds_files_directions, 'filelist', 1)
    else
        echo "No files found in current directory."
    endif
endfunction
