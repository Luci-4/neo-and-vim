" Enable line numbers
set number

" Enable syntax highlighting
syntax on
" Set indentation preferences
set tabstop=4
set shiftwidth=4
set expandtab


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

function! OpenSpecialListBuffer(list, action_map, filetype)
  " Open vertical split with new scratch buffer
  vert new
  setlocal buftype=nofile
  setlocal bufhidden=wipe
  setlocal noswapfile
  setlocal modifiable
  execute 'setlocal filetype=' . a:filetype
  setlocal nobuflisted

  " Set content
  call setline(1, a:list)
  setlocal nomodifiable

  " Apply buffer-local key mappings
  for [key, func] in items(a:action_map)
    execute 'nnoremap <buffer> ' . key . ' :call ' . func . '()<CR>'
  endfor
endfunction

function! ListFilesInBuffer()
  let l:cwd = getcwd()
  let l:full_paths = globpath(l:cwd, '**/*', 0, 1)
  let l:files = map(l:full_paths, {_, val -> fnamemodify(val, ':.' )})

  call OpenSpecialListBuffer(l:files, {'<CR>': 'OpenFileUnderCursor'}, 'filelist')
endfunction

function! OpenFileUnderCursor()
  let l:file = getline('.')
  if filereadable(l:file)
    execute 'edit ' . fnameescape(l:file)
  else
    echo "File does not exist: " . l:file
  endif
endfunction

nnoremap <Leader>lf :call ListFilesInBuffer()<CR>

function! ListBranches()
  let l:branches = split(system('git branch --all'), "\n")
  call OpenSpecialListBuffer(l:branches, {'<CR>': 'CheckoutBranch'}, 'branchlist')
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
  call OpenSpecialListBuffer(l:lines, {}, 'messagesbuffer')
endfunction

nnoremap <Leader>lm :call ShowMessagesInBuffer()<CR>
" Toggle between current and last buffer
nnoremap <leader><leader> <c-^>

" Resize window height
function! IncreaseSize()
  resize +1
endfunction

function! DecreaseSize()
  resize -1
endfunction

" Resize window width
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
