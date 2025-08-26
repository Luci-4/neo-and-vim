let s:config_path = split(&runtimepath, ',')[0]

execute 'source' s:config_path . '/spectroscope/spectroscope.vim'
execute 'source' s:config_path . './spectroscope/bind_groups.vim'

let s:current_list = []
let s:action_map = {}
let s:filetype = ''

function! s:FilterList(pattern)
  if a:pattern == ''
    let l:filtered = s:current_list
  else
    let l:filtered = filter(copy(s:current_list), 'v:val =~ a:pattern')
  endif

  call setbufvar('%', '&modifiable', 1)
  call setline(1, l:filtered)
  call deletebufline('%', len(l:filtered) + 1, '$')
  call setbufvar('%', '&modifiable', 0)
endfunction


function! OpenSpecialListBufferWithSearch_PromptFilter()
  let l:pattern = input('Filter: ')
  call s:FilterList(l:pattern)
endfunction
function! OpenSpecialListBufferWithSearch(list, action_map, filetype)
  let s:current_list = a:list
  let s:action_map = a:action_map
  let s:filetype = a:filetype

  vert enew
  setlocal buftype=nofile
  setlocal bufhidden=wipe
  setlocal noswapfile
  setlocal modifiable
  execute 'setlocal filetype=' . a:filetype
  setlocal nobuflisted

  call setline(1, a:list)
  setlocal nomodifiable

    for [key, func] in items(a:action_map)
      execute 'nnoremap <buffer> ' . key . ' :call ' . func . '(getline("."))<CR>'
    endfor

  nnoremap <buffer> / :call OpenSpecialListBufferWithSearch_PromptFilter()<CR>
endfunction


function! ListFilesInBufferWithSearch()
  let l:cwd = getcwd()
  let l:full_paths = globpath(l:cwd, '**/*', 0, 1)
  let l:files = map(l:full_paths, {_, val -> fnamemodify(val, ':.' )})

  call OpenSpecialListBufferWithSearch(l:files, g:spectroscope_files_binds, 'filelist')
endfunction
