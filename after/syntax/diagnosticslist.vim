syntax match DiagError /^E\s[^:]\+/ 
syntax match DiagWarn  /^W\s[^:]\+/ 
syntax match DiagInfo  /^I\s[^:]\+/ 

syntax match DiagFile /:\zs.*\ze:/ 

syntax match DiagLine /:\d\+$/ 

highlight default link DiagError Error
highlight default link DiagWarn  WarnMsg
highlight default link DiagInfo  InfoMsg

highlight default link DiagFile Directory
highlight default link DiagLine Number
