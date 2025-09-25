function! RunTermCommand(cmd) abort
    botright split
    execute has('nvim') ? 'terminal' : 'term'
    resize 15
    call chansend(b:terminal_job_id, a:cmd . "\n")
endfunction

function! RunPythonFile() abort
    let l:file = expand('%')
    return 'python3 ' . shellescape(l:file)
endfunction

let g:term_commands = {
\ 'run_python_file': {'func': function('RunPythonFile'), 'desc': 'Run current python file'},
\ }

