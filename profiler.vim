" profiler stuff
let s:config_path = split(&runtimepath, ',')[0]

if !exists('g:profile_mode')
    " modes: 'print' | 'log' | 'silent'
    let g:profile_mode = 'silent'
endif
if !exists('g:profile_logfile')
    let g:profile_logfile = s:config_path . '/profile.log'
endif

if !exists('s:profile_times')
    let s:profile_times = {}  
endif
if !exists('s:profile_results')
    let s:profile_results = {} 
endif

function! ProfileStart(name) abort
    let s:profile_times[a:name] = reltime()
endfunction

function! ProfileEnd(name) abort
    if !has_key(s:profile_times, a:name)
        return
    endif
    let l:elapsed = reltime(s:profile_times[a:name])
    let l:elapsed_str = reltimestr(l:elapsed)
    let l:msg = printf("[PROFILE] %s: %s", a:name, l:elapsed_str)

    if !has_key(s:profile_results, a:name)
        let s:profile_results[a:name] = []
    endif
    call add(s:profile_results[a:name], l:elapsed)

    if g:profile_mode ==# 'print'
        echom l:msg
    elseif g:profile_mode ==# 'log'
        call writefile([l:msg], g:profile_logfile, 'a')
    endif

    call remove(s:profile_times, a:name)
endfunction

function! ProfileSummary() abort
    for l:name in keys(s:profile_results)
        let l:list = s:profile_results[l:name]
        let l:count = len(l:list)
        let l:total = 0.0
        for l:t in l:list
            let l:total += str2float(reltimestr(l:t))
        endfor
        let l:avg = l:total / l:count
        echom printf("[SUMMARY] %s: runs=%d avg=%.6f total=%.6f", l:name, l:count, l:avg, l:total)
    endfor
endfunction

function! ProfileClear() abort
    let s:profile_results = {}
endfunction
