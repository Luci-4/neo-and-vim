let s:config_path = split(&runtimepath, ',')[0]
execute 'source' s:config_path . '/spectroscope/files.vim'
execute 'source' s:config_path . '/spectroscope/filter_files.vim'
execute 'source' s:config_path . '/spectroscope/git.vim'
execute 'source' s:config_path . '/spectroscope/messages.vim'
execute 'source' s:config_path . '/spectroscope/vimgrep.vim'

let mapleader = "\<Space>"

nnoremap <Leader>fr :call ListRecentFilesInBuffer()<CR>
nnoremap <Leader>gb :call ListBranches()<CR>
nnoremap <Leader>lm :call ShowMessagesInBuffer()<CR>
nnoremap <Leader>ff :call ListFilesInBufferWithSearch()<CR>
nnoremap <Leader>fs :call FilesBySubstringWithSearch()<CR>

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
nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <A-l> <C-w>l

nnoremap <C-k> :call IncreaseSize()<CR>
nnoremap <C-j> :call DecreaseSize()<CR>
nnoremap <C-l> :call IncreaseWidth()<CR>
nnoremap <C-h> :call DecreaseWidth()<CR>

nnoremap <C-M-j> <C-e>
nnoremap <C-M-k> <C-y>

tnoremap <Esc> <C-\><C-n>

nnoremap <leader><CR> :execute 'terminal python ' . expand('%:p')<CR>
