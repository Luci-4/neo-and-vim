syntax match DiagError /^E\s[^:]\+/ 
syntax match DiagWarn  /^W\s[^:]\+/ 
syntax match DiagInfo  /^I\s[^:]\+/ 

syntax match DiagFile /:\zs.*\ze:/ 

syntax match DiagLine /:\d\+$/ 

" highlight DiagError guifg=#ac2958 guibg=#21131f

highlight default link DiagError  DiagnosticError
highlight default link DiagWarn  DiagnosticWarn

highlight default link DiagInfo  Info

highlight default link DiagFile Directory
highlight default link DiagLine Number
