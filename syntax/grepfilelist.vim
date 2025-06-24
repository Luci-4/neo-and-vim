syntax match FilelistFilename /^[^:]\+/
syntax match FilelistLineNumber /:\zs\d\+\ze:/
syntax match FilelistText /:\d\+:\s\zs.*/

highlight default link FilelistFilename Identifier
highlight default link FilelistLineNumber Number
highlight default link FilelistText Comment
