let s:config_path = split(&runtimepath, ',')[0]

let g:colors = {"blue": "#4DA4EA", "green": "#3CB043", "red": "#C21807", "cyan": "#40e0D0"}

augroup MarkdownPreview
    autocmd!
    autocmd BufWritePost *.md call RenderMarkdownToHTML()
augroup END

" working
" syntax region markdownRed matchgroup=markdownRedTag start =/<red>/ end=/<\/red>/ contains=markdown
" syntax match markdownRed /<red>.\{-}<\/red>/ containedin=ALL
" highlight link markdownRed mdRedText

function! RenderMarkdownToHTML()
    let l:mdfile = expand('%:p')
    let l:htmlfile = substitute(l:mdfile, '\.md$', '.html', '')
    let l:lines = getline(1, '$')
    let l:markdown_js = join(map(l:lines, {_, val -> substitute(val, '\\', '\\\\', 'g')}), "\n")
    for color_name in keys(g:colors)
        let color_value = g:colors[color_name]
        let l:markdown_js = substitute(l:markdown_js, '<' . color_name . '>', '<span style="color: ' . color_value . '">', 'g')
        let l:markdown_js = substitute(l:markdown_js, '</' . color_name . '>', '</span>', 'g')
    endfor  
    let l:markdown_js = substitute(l:markdown_js, '`', '\\`', 'g')
    let l:markdown_js = substitute(l:markdown_js, '`', '\\`', 'g')
    let l:markdown_js = substitute(l:markdown_js, "'", "\\'", 'g')
    let l:markdown_js = substitute(l:markdown_js, "\r", '', 'g')
    let l:markdown_js = substitute(l:markdown_js, "\n", '\\n', 'g')
    let l:html_lines = [
                \ '<!DOCTYPE html>',
\ '<html>',
\ '<head>',
\ '  <meta charset="UTF-8">',
\ '  <title>Markdown Preview - '.expand('%:t').'</title>',
\ '  <script src=https://cdn.jsdelivr.net/npm/marked/marked.min.js></script>',
\ '  <style>',
\ '    body { font-family: sans-serif; padding: 2em; max-width: 800px; margin: auto; background: #121212; color: #e0e0e0 !important;}',
\ '  </style>',
\ '</head>',
\ '<body>',
\ '  <div id="preview"></div>',
\ '  <script>',
\ '    const markdown = `'.l:markdown_js.'`;',
\ '    document.getElementById("preview").innerHTML = marked.parse(markdown);',
\ '  </script>',
\ '</body>',
\ '</html>'
\ ]

call writefile(l:html_lines, l:htmlfile)
execute 'silent !start "" '.shellescape(l:htmlfile)
endfunction

function! SaveClipboardImage()
    let l:img_dir = getcwd() . '/img'
    if !isdirectory(l:img_dir)
        silent call mkdir(l:img_dir)
    endif

    let l:files = split(globpath(l:img_dir, '*.png'), '\n')
    let l:max_num = 0
    for l:file in l:files
        let l:fname = fnamemodify(l:file, ':t')     " Get filename only
        if l:fname =~ '^\d\+\.png$'
            let l:num = str2nr(matchstr(l:fname, '^\d\+'))
            if l:num > l:max_num
                let l:max_num = l:num
            endif
        endif
    endfor
    let l:next_num = l:max_num + 1
    let l:rel_img_path = 'img/' . l:next_num . '.png'
    let l:filepath = l:img_dir . '/' . l:next_num . '.png'
    let l:ps_script = s:config_path . '/save_clipboard_image.ps1'
    let l:cmd = 'powershell -ExecutionPolicy Bypass -File "' . l:ps_script . '" "' . l:filepath . '"'
    let l:cmd_status = system(l:cmd)
    echom '|' . cmd_status
    if (l:cmd_status == 1)
        call append(line("."), '![' . l:next_num . '](' . rel_img_path . ')')
    endif
endfunction

augroup MarkdownPasteImage
    autocmd!
    autocmd FileType markdown nnoremap <buffer> <Leader>p :call SaveClipboardImage()<CR>
augroup END
