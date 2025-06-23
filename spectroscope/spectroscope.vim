function! OpenSpecialListBuffer(list, action_map, filetype, vertical)
  if a:vertical
    vertical enew
  else
    enew
  endif

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
endfunction
