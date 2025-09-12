function! BlendColor(base, target, percent) abort
    let br = str2nr(a:base[1:2], 16)
    let bg = str2nr(a:base[3:4], 16)
    let bb = str2nr(a:base[5:6], 16)

    let tr = str2nr(a:target[1:2], 16)
    let tg = str2nr(a:target[3:4], 16)
    let tb = str2nr(a:target[5:6], 16)

    let r = float2nr(br + (tr - br) * a:percent / 100)
    let g = float2nr(bg + (tg - bg) * a:percent / 100)
    let b = float2nr(bb + (tb - bb) * a:percent / 100)

    return printf('#%02x%02x%02x', r, g, b)
endfunction

function! SetGitHighlights() abort
    let bg = synIDattr(hlID('Normal'), 'bg', 'gui')
    if empty(bg)
        let bg = (&background ==# 'dark' ? '#000000' : '#ffffff')
    endif

    let base_added   = '#00ff00' 
    let base_deleted = '#ff0000' 
    let base_changed = '#0000ff' 

    let added_bg   = BlendColor(bg, base_added, 10)
    let deleted_bg = BlendColor(bg, base_deleted, 10)
    let changed_bg = BlendColor(bg, base_changed, 10)

    execute 'highlight GitAdded   guibg=' . added_bg   . ' ctermbg=NONE'
    execute 'highlight GitDeleted guibg=' . deleted_bg . ' ctermbg=NONE'
    execute 'highlight GitChanged guibg=' . changed_bg . ' ctermbg=NONE'
endfunction

function! PlaceGitHighlights() abort
    if exists('w:git_matches')
        for id in w:git_matches
            call matchdelete(id)
        endfor
    endif
    let w:git_matches = []

    let l:filepath = expand('%:p')
    if empty(l:filepath) || !filereadable(l:filepath)
        return
    endif


    let l:cmd = 'git diff -U0 -- ' . shellescape(l:filepath) . 
                \ ' | grep "^@@" | sed -E "s/^@@ .*\\+([0-9]+)(,([0-9]+))? @@.*$/\\1,\\3/"'
    let l:diff_hunks = systemlist(l:cmd)
    if v:shell_error != 0 || empty(l:diff_hunks)
        return
    endif
    for hunk in l:diff_hunks
        let l:parts = split(hunk, ',')
        let l:start = str2nr(l:parts[0])
        let l:len = (len(l:parts) > 1 && !empty(l:parts[1])) ? str2nr(l:parts[1]) : 1

        let l:lines = range(l:start, l:start + l:len - 1)

        if !empty(l:lines)
            let id = matchaddpos('GitAdded', l:lines)
            call add(w:git_matches, id)
        endif
    endfor
endfunction

call SetGitHighlights()

augroup git_highlight
    autocmd!
    autocmd BufEnter,BufWritePost,TextChanged,TextChangedI * call PlaceGitHighlights()
augroup END

