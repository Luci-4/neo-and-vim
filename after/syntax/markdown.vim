for color_name in keys(g:colors)
    let color_value = g:colors[color_name]
    let syntaxName = 'md' . color_name . 'Text'
    let startTag = '<' . color_name . '>'
    let endTag = '</' . color_name . '>'
    execute 'highlight ' . syntaxName . ' guifg=' . color_value
    execute 'syntax region ' . syntaxName . ' start=+' . startTag . '+ end=+' . endTag . '+ keepend contains=NONE oneline containedin=ALL'
    "syntax region mdRedText start=+<red>+ end=+</red>+ keepend contains=NONE oneline

    "highlight mdRedText guifg=Red ctermfg=Red
endfor
