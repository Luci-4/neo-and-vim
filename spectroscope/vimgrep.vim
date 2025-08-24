let s:config_path = split(&runtimepath, ',')[0]

execute 'source' s:config_path . '/spectroscope/spectroscope.vim'

let s:current_list = []
let s:action_map = {}
let s:filetype = ''

function! s:UpdateList(pattern)
  " Use glob to get file list (replace expand with glob to get list)
  let l:files = glob('./**/*', 0, 1)
  if empty(l:files)
    echo "No files found."
    return
  endif

  " Run vimgrep on files silently
  silent! execute 'vimgrep /' . escape(a:pattern, '/\') . '/gj ' . join(l:files, ' ')

  let l:qf = getqflist()

  let l:filtered = []
  for l:item in l:qf
    if has_key(l:item, 'bufnr') && has_key(l:item, 'lnum') && has_key(l:item, 'text')
      let l:file = fnamemodify(bufname(l:item.bufnr), ':.')
      " Format: filename:line: text
      call add(l:filtered, printf('%s:%d: %s', l:file, l:item.lnum, l:item.text))
    endif
  endfor

  call setbufvar('%', '&modifiable', 1)
  if empty(l:filtered)
    call setline(1, ['[No matches found]'])
  else
    call setline(1, l:filtered)
  endif
  call deletebufline('%', len(l:filtered) + 1, '$')
  call setbufvar('%', '&modifiable', 0)
  execute 'file [Filtered: ' . a:pattern . ']'
endfunction

" Function to open file and jump to line based on a line from the displayed list
function! OpenSelectedLine(line)
  " relative/path/to/file:123: matching text"

  let l:matches = matchlist(a:line, '\v^(.*):(\d+):')

  if len(l:matches) < 3
    echo "Invalid line format!"
    return
  endif

  let l:file = l:matches[1]
  let l:lnum = str2nr(l:matches[2])

  if filereadable(l:file)
    execute 'edit +' . l:lnum . ' ' . fnameescape(l:file)
  else
    echo "File not found: " . l:file
  endif
endfunction

function! OpenSpecialListBufferWithSearch(list, action_map, filetype)
  let s:current_list = a:list
  let s:action_map = a:action_map
  let s:filetype = a:filetype

  vert new
  setlocal buftype=nofile
  setlocal bufhidden=wipe
  setlocal noswapfile
  setlocal modifiable
  execute 'setlocal filetype=' . a:filetype
setlocal cursorline
highlight CursorLine ctermbg=LightGrey guibg=#555555
  setlocal nobuflisted

  call setline(1, a:list)
  setlocal nomodifiable

    for [key, func] in items(a:action_map)
      execute 'nnoremap <buffer> ' . key . ' :call ' . func . '(getline("."))<CR>'
    endfor

  nnoremap <buffer> / :call OpenSpecialListBufferWithSearch_PromptFilter()<CR>
endfunction

function! OpenSpecialListBufferWithSearch_PromptFilter()
  let l:pattern = input('Filter: ')
  call s:UpdateList(l:pattern)
endfunction

function! FilesBySubstringWithSearch()
    call OpenSpecialListBufferWithSearch([], {'<CR>': 'OpenSelectedLine', '<S-h>': 'OpenFileVSplitRight'}, 'grepfilelist')
endfunction
