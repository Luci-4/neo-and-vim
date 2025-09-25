let s:config_path = split(&runtimepath, ',')[0]
execute 'source' s:config_path . '/spectroscope/files.vim'
execute 'source' s:config_path . '/spectroscope/grep.vim'
execute 'source' s:config_path . '/spectroscope/messages.vim'
execute 'source' s:config_path . '/spectroscope/commands.vim'
execute 'source' s:config_path . '/spectroscope/terminal.vim'
execute 'source' s:config_path . '/comments.vim'
execute 'source' s:config_path . '/terminal.vim'

let mapleader = "\<Space>"

" nnoremap <Leader>gb :call ListBranches()<CR>
nnoremap <Leader>lm :call ShowMessagesInBuffer()<CR>
nnoremap <Leader>ff :call FindFiles()<CR>
nnoremap <Leader>fr :call ListRecentFilesInBuffer(1)<CR>


nnoremap <Leader>fs :call FindFilesWithFilter()<CR>
nnoremap <Leader>fh :call LastFilesWithFilter()<CR>



nnoremap <leader>/ :call FindStringWithFilter()<CR>
nnoremap <leader>* :call FindStringWordUnderCursorWithFilter()<CR>

" nnoremap <Leader>fs :call FilesBySubstringWithSearch()<CR>

nnoremap <Leader>ct :call ListTermCommands()<CR>

nnoremap <leader>to :call OpenNewTerminal()<CR>
nnoremap <leader>tt :call ToggleLastTerminal()<CR>
nnoremap <leader>tp :call PrevTerminal()<CR>
nnoremap <leader>tn :call NextTerminal()<CR>
nnoremap <leader>tl :call ListTerminals()<CR>


nnoremap <leader><leader> <c-^>

function! IncreaseSize()
    resize +10
endfunction

function! DecreaseSize()
    resize -10
endfunction

function! IncreaseWidth()
    execute "10 wincmd >"
endfunction

function! DecreaseWidth()
    execute "10 wincmd <"
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

nnoremap <C-/> :call ToggleComment()<CR>
xnoremap <C-/> :call ToggleComment()<CR>

nnoremap <C-_> :call ToggleComment()<CR>
xnoremap <C-_> :call ToggleComment()<CR>

nnoremap <leader>s :%s/\<<C-r><C-w>\>/<C-r><C-w>/gc<Left><Left><Left>
vnoremap <leader>s :s/\<<C-r><C-w>\>/<C-r><C-w>/g<Left><Left>
nnoremap <Leader>r <C-w>r
nnoremap <Leader>R <C-w>R
