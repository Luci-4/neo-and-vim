let s:config_path = expand('~/.vim')
execute 'source' s:config_path . '/spectroscope/spectroscope.vim'

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
    call OpenSpecialListBuffer(l:recent_files, {'<CR>': 'OpenFile', '<S-h>': 'OpenFileVSplitRight'}, 'recentfiles', 0)
  endif
endfunction

augroup RecentFilesListOnStart
  autocmd!
  autocmd VimEnter * if argc() == 0 | call ListRecentFilesInBuffer() | endif
augroup END
