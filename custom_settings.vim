let s:config_path = split(&runtimepath, ',')[0]
execute 'source' s:config_path . '/system_check.vim'    

let g:git_changed_highlights_enabled = 0
let g:lsp_syntax_highlights_enabled = 1
let g:lsp_syntax_highlights_priority = 12
let g:git_changed_highlights_priority = 11


function! IsInGitRepo()
    if executable('git') != 1   
        return 0
    endif
    let cmd = TernaryIfLinux('git rev-parse --is-inside-work-tree 2>/dev/null', 'git rev-parse --is-inside-work-tree 2>$null')
    let l:result = system(cmd)
    return l:result =~ 'true'

endfunction

let g:has_repo = IsInGitRepo()  
