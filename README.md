# Neo-and-vim

A plugin-free configuration that works with both Neovim and Vim. The only external dependencies are language servers, which must be installed separately. 

## Features

- **Spectroscope**
    - Special buffers that function as pickers, with live *file* and *string* search. 
    - Special buffers for listing and performing custom actions for:
        - opened buffers
        - LSP diagnostics
        - LSP references
        - custom generated terminal commands 
        - Vim messages
    - Extendable with any lists
- **LSP** 
    - Lua support for Neovim and Vimscript support for Vim (in progress; still not fully abstracted) 
    - Status line breadcrumbs
    - Rich syntax highlighting

- **Git gutter**

- **Markdown**
    - Output html generation with additional custom color tags that are highlighted both in input .md and in output .html 
    - Ability to paste an image from the clipboard on Windows   

- **Terminal**
    - Command palette and runner 
    - Single terminal instance management in the second tab (assumes tabs are not used) 

## Requirements
- Neovim 0.11.2 or Vim 9.1 
- Windows >=10 or Linux
- Language servers installed for your languages of choice


## Some binds
---

**General**  

`Space`+`Space` → Switch between last two buffers  
`Space`+`Enter` → Run current Python file in terminal (a placeholder for now, later might be some fast command run) 

**Files & Buffers**  

`Space`+`ff` → List files  
`Space`+`fr` → List recent files  
`Space`+`fs` → Find files with live search  
`Space`+`fh` → Show last file search  
`Space`+`bb` → List recent buffers  

**String Search**  

`Space`+`/` → Live search string  
`Space`+`*` → Live search word under cursor  

**Messages & Terminals**  

`Space`+`lm` → Show messages in buffer  
`Space`+`ct` → Compose & list terminal commands  
`Space`+`t` → Toggle single terminal  
`Esc` → Exit terminal mode 

**LSP**

`gd` → go to definition  
`gr` → list references  
`Space`+`ds` → list diagnostics  
`fl` → format file  
Visual mode + `fl` → format selection  
`K` → hover  

**Window Navigation, Resizing and Movement**  

`Alt`+`h/j/k/l` → Move between windows  
`Tab`+`k` → Increase window height  
`Tab`+`j` → Decrease window height  
`Tab`+`l` → Increase window width  
`Tab`+`h` → Decrease window width  
`Space`+`r` → Rotate windows clockwise  
`Space`+`R` → Rotate windows counterclockwise

**Scrolling**  

`Ctrl`+`Alt`+`j` → Scroll down  
`Ctrl`+`Alt`+`k` → Scroll up  

**Commenting**  

`Ctrl`+`/` → Toggle comment  

**Search & Replace**  

`Space`+`s*` → Search & replace word under cursor  
Visual mode + `Space`+`sa` → Search & replace the word at the start of the selection inside the selection  
Visual mode + `Space`+`sc` → Search & replace the selected word  



