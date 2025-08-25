let s:config_path = split(&runtimepath, ',')[0]

execute 'source' s:config_path . '/spectroscope/spectroscope.vim'

function! ShowMessagesInBuffer()
  redir => l:msgs
  silent messages
  redir END

  let l:lines = split(l:msgs, "\n")
  call OpenSpecialListBuffer(l:lines, {}, 'messagesbuffer', 1, 1)
endfunction
