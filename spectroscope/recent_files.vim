let s:config_path = split(&runtimepath, ',')[0]
execute 'source' s:config_path . '/spectroscope/spectroscope.vim'
execute 'source' s:config_path . '/spectroscope/bind_groups.vim'

let g:recent_files = []

function! InitRecentFiles()
    let g:recent_files = []
    for file in v:oldfiles
        if filereadable(file)
            let l:relpath = fnamemodify(file, ':.')
            if l:relpath !=# file
                call add(g:recent_files, l:relpath)
            endif
        endif
    endfor
endfunction
function! AddToRecentFiles(file)
    let l:relpath = fnamemodify(a:file, ':.')
    if index(g:recent_files, l:relpath) == -1
        call add(g:recent_files, l:relpath)
    endif
endfunction

function! ListRecentFilesInBuffer(vertical)
    if !empty(g:recent_files)
        call OpenSpecialListBuffer(g:recent_files, g:spectroscope_files_binds, 'recentfiles', a:vertical, 0)
    endif
endfunction

augroup RecentFiles
    autocmd!
    autocmd BufReadPost * call AddToRecentFiles(expand('%:p'))
augroup END

call InitRecentFiles()
