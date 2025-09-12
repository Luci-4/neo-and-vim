syntax match GrepResultsFilename /^[^:]\+/

syntax match GrepResultsLineNumber /:\zs\d\+\ze:/

syntax match GrepResultsText /:\d\+:\d\+:\zs.*/
syntax match GrepResultsTextNoCol /:\d\+:\zs.*/ containedin=ALL

highlight default link GrepResultsFilename Identifier
highlight default link GrepResultsLineNumber Number
highlight default link GrepResultsText Comment
highlight default link GrepResultsTextNoCol Comment

syntax include @CodeSyntax syntax/cpp.vim
syntax region GrepResultsCode start=/:\d\+:\d\+:/ end=/$/ contains=@CodeSyntax
