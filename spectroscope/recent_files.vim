let s:config_path = fnamemodify($MYVIMRC, ':h')
execute 'source' s:config_path . '/spectroscope/spectroscope.vim'

" Global variable to store recent files in the session
let g:recent_files = []

" Initialize recent files once on startup
function! InitRecentFiles()
  let g:recent_files = []
  for file in v:oldfiles
    let l:relpath = fnamemodify(file, ':.')
    if l:relpath !=# file
      call add(g:recent_files, l:relpath)
    endif
  endfor
endfunction

" Add a new file to recent files list if not already present
function! AddToRecentFiles(file)
  let l:relpath = fnamemodify(a:file, ':.')
  if index(g:recent_files, l:relpath) == -1
    call add(g:recent_files, l:relpath)
  endif
endfunction

" Show recent files in a special buffer
function! ListRecentFilesInBuffer()
  if !empty(g:recent_files)
    call OpenSpecialListBuffer(g:recent_files, {'<CR>': 'OpenFile', '<S-h>': 'OpenFileVSplitRight'}, 'recentfiles', 0)
  endif
endfunction

" Autocommand to update recent files on BufRead
augroup RecentFiles
  autocmd!
  autocmd BufReadPost * call AddToRecentFiles(expand('%:p'))
augroup END

" Call once at startup
call InitRecentFiles()
