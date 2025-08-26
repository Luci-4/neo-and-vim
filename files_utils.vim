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

function! OpenFile(file)
  if filereadable(a:file)
    execute 'edit ' . fnameescape(a:file)
  else
    echo "File does not exist: " . a:file
  endif
endfunction

function! OpenFileVSplitRight(file)
  if filereadable(a:file)
    " Open file in a vertical split on the right (default)
    execute 'vsplit ' . fnameescape(a:file)
  else
    echo "File does not exist: " . a:file
  endif
endfunction

function s:open_file_in_direction(file, direction)
    if empty(a:file)
        echo "No file under cursor"
        return
    endif
    execute "wincmd " . a:direction
    execute "edit " . fnameescape(a:file)
endfunction

function! OpenFileInWindowInDirectionH(file)
    call s:open_file_in_direction(a:file, 'h')
endfunction

function! OpenFileInWindowInDirectionJ(file)
    call s:open_file_in_direction(a:file, 'j')
endfunction

function! OpenFileInWindowInDirectionK(file)
    call s:open_file_in_direction(a:file, 'k')
endfunction

function! OpenFileInWindowInDirectionL(file)
    call s:open_file_in_direction(a:file, 'l')
endfunction
