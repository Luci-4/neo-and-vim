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


function! TrackedFilesWithStatus()
    let l:raw = systemlist("git status --porcelain=v1")
    let l:files = []

    for l:line in l:raw
        " split into status and filename
        let l:status = strpart(l:line, 0, 2)
        let l:file   = strpart(l:line, 3)

        call add(l:files, {
        \ 'file': l:file,
        \ 'staged': l:status[0],
        \ 'unstaged': l:status[1],
        \ })
    endfor

    call OpenSpecialListBuffer(l:files, {}, "gitstatus", 1)
endfunction

function! GitAddFile(file)
    execute 'git add ' . a:file
endfunction

function! GitRestoreFile(file)
    execute 'git restore ' . a:file
endfunction
