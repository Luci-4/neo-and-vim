let s:config_path = split(&runtimepath, ',')[0]

execute 'source' s:config_path . '/spectroscope/spectroscope.vim'
execute 'source' s:config_path . './spectroscope/bind_groups.vim'

function! ListFilesInBuffer()
  let l:cwd = getcwd()
  let l:full_paths = globpath(l:cwd, '**/*', 0, 1)
  let l:files = map(l:full_paths, {_, val -> fnamemodify(val, ':.' )})

  call OpenSpecialListBuffer(l:files, g:spectroscope_files_binds, 'filelist', 1)
endfunction

