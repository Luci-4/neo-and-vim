" Enable line numbers
set number

" Enable syntax highlighting
syntax on
" Set indentation preferences
set tabstop=4
set shiftwidth=4
set expandtab

set nowrap

set noswapfile


" Show line and column number in the status line
set ruler

" Enable search highlighting
set hlsearch

" Show matching parentheses and brackets
set showmatch

" Enable auto-completion
set completeopt=menu,menuone,noselect

" Set clipboard to use the system clipboard
set clipboard=unnamedplus

" Enable mouse support
set mouse=a

" Set the default file encoding
set encoding=utf-8
set termguicolors
colorscheme purpura
let mapleader = "\<Space>"
if has("win32") || has("win64")
    " \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ no escape
else
    :nnoremap <leader>ev :vsplit $MYVIMRC<cr>
    :nnoremap <leader>sv :source $MYVIMRC<cr>
endif

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
    execute 'nnoremap <buffer> ' . key . ' :call ' . func . '()<CR>'
  endfor
endfunction

function! ListFilesInBuffer()
  let l:cwd = getcwd()
  let l:full_paths = globpath(l:cwd, '**/*', 0, 1)
  let l:files = map(l:full_paths, {_, val -> fnamemodify(val, ':.' )})

  call OpenSpecialListBuffer(l:files, {'<CR>': 'OpenFileUnderCursor', '<S-h>': 'OpenFileUnderCursorVSplitRight'}, 'filelist', 1)
endfunction

function! OpenFileUnderCursor()
  let l:file = getline('.')
  if filereadable(l:file)
    execute 'edit ' . fnameescape(l:file)
  else
    echo "File does not exist: " . l:file
  endif
endfunction

function! OpenFileUnderCursorVSplitRight()
  let l:file = getline('.')
  if filereadable(l:file)
    " Open file in a vertical split on the right (default)
    execute 'vsplit ' . fnameescape(l:file)
  else
    echo "File does not exist: " . l:file
  endif
endfunction


nnoremap <Leader>lf :call ListFilesInBuffer()<CR>

function! ListBranches()
  let l:branches = split(system('git branch --all'), "\n")
  call OpenSpecialListBuffer(l:branches, {'<CR>': 'CheckoutBranch'}, 'branchlist', 1)
endfunction

function! CheckoutBranch()
  let l:branch = substitute(getline('.'), '^\* ', '', '')
  execute 'git checkout ' . shellescape(l:branch)
endfunction

nnoremap <Leader>gb :call ListBranches()<CR>

function! ShowMessagesInBuffer()
  redir => l:msgs
  silent messages
  redir END

  let l:lines = split(l:msgs, "\n")
  call OpenSpecialListBuffer(l:lines, {}, 'messagesbuffer', 1)
endfunction

nnoremap <Leader>lm :call ShowMessagesInBuffer()<CR>
" Toggle between current and last buffer
nnoremap <leader><leader> <c-^>

function! IncreaseSize()
  resize +10
endfunction

function! DecreaseSize()
  resize -10
endfunction

function! IncreaseWidth()
  execute "wincmd >"
endfunction

function! DecreaseWidth()
  execute "wincmd <"
endfunction

nnoremap <Esc>h <C-w>h
nnoremap <Esc>j <C-w>j
nnoremap <Esc>k <C-w>k
nnoremap <Esc>l <C-w>l

nnoremap <C-k> :call IncreaseSize()<CR>
nnoremap <C-j> :call DecreaseSize()<CR>
nnoremap <C-l> :call IncreaseWidth()<CR>
nnoremap <C-h> :call DecreaseWidth()<CR>

nnoremap <C-M-j> <C-e>
nnoremap <C-M-k> <C-y>

tnoremap <Esc> <C-\><C-n>

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
  setlocal nobuflisted

  call setline(1, a:list)
  setlocal nomodifiable

  for [key, func] in items(a:action_map)
    execute 'nnoremap <buffer> ' . key . ' :call ' . func . '()<CR>'
  endfor

  nnoremap <buffer> / :call OpenSpecialListBufferWithSearch_PromptFilter()<CR>
endfunction

function! OpenSpecialListBufferWithSearch_PromptFilter()
  let l:pattern = input('Filter: ')
  call s:FilterList(l:pattern)
endfunction

function! ListFilesInBufferWithSearch()
  let l:cwd = getcwd()
  let l:full_paths = globpath(l:cwd, '**/*', 0, 1)
  let l:files = map(l:full_paths, {_, val -> fnamemodify(val, ':.' )})

  call OpenSpecialListBufferWithSearch(l:files, {'<CR>': 'OpenFileUnderCursor', '<S-h>': 'OpenFileUnderCursorVSplitRight'}, 'filelist')
endfunction

nnoremap <Leader>ff :call ListFilesInBufferWithSearch()<CR>




set statusline=%f\ %y\ %=Ln:%l\ Col:%c
set termguicolors
highlight StatusLine ctermfg=White ctermbg=DarkBlue guifg=#ffffff guibg=#005f87
highlight StatusLineNC ctermfg=Grey ctermbg=DarkGrey
function! TitleString()
  let cwd = fnamemodify(getcwd(), ':t') 

  let repo = ''
  let branch = ''

  if !empty(finddir('.git', '.;'))
    let toplevel = systemlist('git rev-parse --show-toplevel')[0]
    let repo = fnamemodify(toplevel, ':t')

    
    let branchlist = systemlist('git rev-parse --abbrev-ref HEAD 2>/dev/null')
    if !empty(branchlist)
      let branch = branchlist[0]
    endif
  endif
  
  let parts = ['/' . cwd]
  if repo !=# ''
    call add(parts, repo)
    if branch !=# ''
      call add(parts, ' ' . branch)
    endif
  endif

  return join(parts, ' • ')  
endfunction

set title
autocmd BufEnter,DirChanged * let &titlestring = TitleString()
set shortmess+=I

function! ListRecentFilesInBuffer()
  let l:recent_files = []

  for file in v:oldfiles
    let l:relpath = fnamemodify(file, ':.')

    if l:relpath !=# file
      call add(l:recent_files, l:relpath)
    endif
  endfor

  if !empty(l:recent_files)
    call OpenSpecialListBuffer(l:recent_files, {'<CR>': 'OpenFileUnderCursor', '<S-h>': 'OpenFileUnderCursorVSplitRight'}, 'recentfiles', 0)
  endif
endfunction

augroup RecentFilesListOnStart
  autocmd!
  autocmd VimEnter * if argc() == 0 | call ListRecentFilesInBuffer() | endif
augroup END
