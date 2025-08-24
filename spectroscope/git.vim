let s:config_path = split(&runtimepath, ',')[0]
execute 'source' s:config_path . '/spectroscope/spectroscope.vim'

function! ListBranches()
  let l:branches = split(system('git branch --all'), "\n")
  call OpenSpecialListBuffer(l:branches, {'<CR>': 'CheckoutBranch'}, 'branchlist', 1)
endfunction

function! CheckoutBranch()
  let l:branch = substitute(getline('.'), '^\* ', '', '')
  execute 'git checkout ' . shellescape(l:branch)
endfunction
