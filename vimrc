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

function! ListFilesInBuffer()
  " Get the current working directory
  let l:cwd = getcwd()

  " Get list of all files recursively (full paths)
  let l:full_paths = globpath(l:cwd, '**/*', 0, 1)

  " Convert to relative paths
  let l:files = map(l:full_paths, {_, val -> fnamemodify(val, ':.' )})

  " Open vertical split with new buffer
  vert new
  setlocal buftype=nofile
  setlocal bufhidden=wipe
  setlocal noswapfile
  setlocal modifiable

  " Add relative file paths to the buffer
  call setline(1, l:files)

  " Optional: make buffer unmodifiable
  setlocal nomodifiable
endfunction

" Map to a key, for example <Leader>lf (list files)
nnoremap <Leader>lf :call ListFilesInBuffer()<CR>
