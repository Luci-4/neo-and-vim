let s:config_path = split(&runtimepath, ',')[0]
execute 'source' s:config_path . '/spectroscope/files.vim'
execute 'source' s:config_path . '/spectroscope/grep.vim'
execute 'source' s:config_path . '/spectroscope/messages.vim'
execute 'source' s:config_path . '/spectroscope/commands.vim'
execute 'source' s:config_path . '/spectroscope/terminal.vim'
execute 'source' s:config_path . '/spectroscope/buffers.vim'
execute 'source' s:config_path . '/comments.vim'
execute 'source' s:config_path . '/terminal.vim'

let mapleader = "\<Space>"

nnoremap <leader>v :vsplit<CR>
" nnoremap <Leader>gb :call ListBranches()<CR>
nnoremap <Leader>lm :call ShowMessagesInBuffer()<CR>
nnoremap <Leader>ff :call FindFiles()<CR>
nnoremap <Leader>fr :call ListRecentFilesInBuffer(0)<CR>
nnoremap <Leader>ftf :call FindFilesWithFilter()<CR>
" nnoremap <Leader>fh :call LastFilesWithFilter()<CR>

nnoremap <Leader>bb :call ListBuffers()<CR>

nnoremap <leader>/ :call FindStringWithFilter()<CR>
nnoremap <leader>* :call FindStringWordUnderCursorWithFilter()<CR>

" nnoremap <Leader>fs :call FilesBySubstringWithSearch()<CR>

nnoremap <Leader>ct :call ListTermCommands()<CR>

"nnoremap <leader>to :call OpenNewTerminal()<CR>
nnoremap <leader>t :call ToggleSingleTerminal()<CR>
"nnoremap <leader>tp :call PrevTerminal()<CR>
"nnoremap <leader>tn :call NextTerminal()<CR>
"nnoremap <leader>tl :call ListTerminals()<CR>


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
nnoremap <Esc>x <C-w>x
nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <A-l> <C-w>l
nnoremap <A-x> <C-w>x



nnoremap <Tab>k :call IncreaseSize()<CR>
nnoremap <Tab>j :call DecreaseSize()<CR>
nnoremap <Tab>l :call IncreaseWidth()<CR>
nnoremap <Tab>h :call DecreaseWidth()<CR>

nnoremap <C-M-j> <C-e>
nnoremap <C-M-k> <C-y>

tnoremap <Esc> <C-\><C-n>

nnoremap <leader><CR> :execute 'terminal python ' . expand('%:p')<CR>

nnoremap <C-/> :call ToggleComment()<CR>
xnoremap <C-/> :call ToggleComment()<CR>

nnoremap <C-_> :call ToggleComment()<CR>
xnoremap <C-_> :call ToggleComment()<CR>

nnoremap <leader>s* :%s/\<<C-r><C-w>\>/<C-r><C-w>/gc<Left><Left><Left>
vnoremap <leader>sa :s/\<<C-r><C-w>\>/<C-r><C-w>/g<Left><Left>
vnoremap <leader>sc "sy:%s/<C-r>s/<C-r>s/gc<Left><Left><Left>
nnoremap <Leader>r <C-w>r
nnoremap <Leader>R <C-w>R

if exists('g:use_plugins')
  nnoremap <silent> <leader>fs :lua require('telescope.builtin').find_files()<CR>
  nnoremap <silent> <leader>/ :lua require('telescope.builtin').live_grep()<CR>
  nnoremap <silent> <leader>ftb :lua require('telescope.builtin').buffers()<CR>
  nnoremap <silent> <leader>fth :lua require('telescope.builtin').help_tags()<CR>
  nnoremap <silent> <leader>fto :lua require('telescope.builtin').oldfiles()<CR>
  nnoremap <silent> <leader>ftr :lua require('telescope.builtin').lsp_references()<CR>
  nnoremap <silent> <leader>ftc :lua require('telescope.builtin').commands()<CR>
  nnoremap <silent> <leader>fh :lua require('telescope.builtin').resume()<CR>
endif

function! GitBlameSelection()
    if mode() ==# 'v'
        let start_line = line('v')
        let end_line = line(',')
    else
        let start_line = line('.')
        let end_line = line('.')
    endif

    let filepath = expand('%')
    let command = 'git blame -L '.start_line.','.end_line.' '.filepath
    echom command
    echom blame_output
endfunction

