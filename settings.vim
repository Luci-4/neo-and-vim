let s:config_path = split(&runtimepath, ',')[0]
execute 'source' s:config_path . '/spectroscope/recent_files.vim'
execute 'source' s:config_path . '/system_check.vim'

let &clipboard = TernaryIfLinux('unnamedplus', 'unnamed')
set nohlsearch

" Enable line numbers
set number

let &t_SI = "\e[6 q"  " insert mode: vertical bar
let &t_SR = "\e[4 q"  " replace mode: underline
let &t_EI = "\e[2 q"  " normal mode: block
"Cursor settings:

"  1 -> blinking block
"  2 -> solid block 
"  3 -> blinking underscore
"  4 -> solid underscore
"  5 -> blinking vertical bar
"  6 -> solid vertical bar

" Enable syntax highlighting
syntax on
" Set indentation preferences
set tabstop=4
set shiftwidth=4
set expandtab

set nowrap

set noswapfile
set cmdheight=2

" Show line and column number in the status line
set ruler


" Show matching parentheses and brackets
set showmatch

" Enable auto-completion
set completeopt=menu,menuone,noselect
set complete=.,w,b,u,t,i,d


" Enable mouse support
set mouse=a

" Set the default file encoding
set encoding=utf-8
set termguicolors
colorscheme shado

set laststatus=2
" set statusline=%f\ %y\ %=Ln:%l\ Col:%c
set termguicolors
highlight StatusLine ctermfg=White ctermbg=DarkBlue guifg=#ffffff guibg=#005f87
highlight StatusLineNC ctermfg=Grey ctermbg=DarkGrey

function! TitleString()
    let cwd = fnamemodify(getcwd(), ':t') 

    " let repo = ''
    " let branch = ''

    " if !empty(finddir('.git', '.;'))
    "   let toplevel = systemlist('git rev-parse --show-toplevel')[0]
    "   let repo = fnamemodify(toplevel, ':t')

    "   
    "   let branchcmd = TernaryIfLinux('git rev-parse --abbrev-ref HEAD 2>/dev/null', 'git rev-parse --is-inside-work-tree')
    "   let branchlist = systemlist(branchcmd)
    "   if !empty(branchlist)
    "     let branch = branchlist[0]
    "   endif
    " endif

    let parts = ['/' . cwd]
    " if repo !=# ''
    "   call add(parts, repo)
    "   if branch !=# ''
    "     call add(parts, ' ' . branch)
    "   endif
    " endif

    return join(parts, ' • ')  
endfunction

set title
autocmd BufEnter,DirChanged * let &titlestring = TitleString()
set shortmess+=I



augroup RecentFilesListOnStart
    autocmd!
    autocmd VimEnter * call InitRecentFiles()
    autocmd VimEnter * if argc() == 0 | call ListRecentFilesInBuffer() | endif
augroup END

autocmd FileType python setlocal tabstop=4 shiftwidth=4
set signcolumn=yes

function! SetStatusLine()
    set statusline=%f\ %y\ %{g:breadcrumbs}\ %=Ln:%l\ Col:%c
endfunction

autocmd VimEnter * if get(g:, 'breadcrumbs', '') !=# '' | call SetStatusLine() | endif
set belloff=all
